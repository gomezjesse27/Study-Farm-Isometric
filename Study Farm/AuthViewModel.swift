//
//  AuthViewModel.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/20/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore



class AuthViewModel: ObservableObject {
    var studySessions: [StudySession] = []
    @Published var isSignedIn = false
    @Published var errorMessage = ""
    @Published var userAnimals: [Animal] = []
    @Published var friendAnimals: [Animal] = []
    //@Published var friendRequests: [String] = []
    @Published var friendRequests: [User] = []
    @Published var friends: [User] = []
    var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    let db = Firestore.firestore()
    
    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // User is signed in
                self.isSignedIn = true
                print("User is signed in with uid:", user.uid)
            } else {
                // User is signed out
                self.isSignedIn = false
                print("User is signed out.")
            }
        }
        
    }
    
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(email: String, password: String) {
        // Reset error message
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.isSignedIn = true
            }
        }
    }
    func saveUserCurrency(_ currency: Int) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        db.collection("users").document(user.uid).setData([
            "currency": currency
        ], merge: true) { error in
            if let error = error {
                print("Error writing currency: \(error)")
            }
        }
    }
    
    func getUserCurrency(completion: @escaping (Int) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                print("Error reading currency: \(error)")
            } else {
                let currency = document?.get("currency") as? Int ?? 0
                completion(currency)
            }
        }
    }
    func incrementUserAnimalCount(animalName: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let animalDocument = db.collection("users").document(user.uid).collection("animals").document(animalName)
        
        animalDocument.getDocument { (document, error) in
            if let error = error {
                print("Error getting animal count: \(error)")
            } else {
                var currentCount = document?.get("count") as? Int ?? 0
                currentCount += 1
                animalDocument.setData([
                    "name": animalName,
                    "count": currentCount
                ]) { error in
                    if let error = error {
                        print("Error writing animal count: \(error)")
                    }
                }
            }
        }
    }
    
    func createAccount(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            guard let result = result, error == nil else {
                // An error occurred
                return
            }
            
            // User successfully created, now add email to Firestore
            let userId = result.user.uid
            let lowercasedEmail = email.lowercased()
            self.db.collection("users").document(userId).setData(["email": lowercasedEmail]) { error in
                if let error = error {
                    print("Error adding email to Firestore: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
            }
        }
    }
    
    func createAccount(email: String, password: String, confirmPassword: String) {
        // Reset error message
        errorMessage = ""
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.isSignedIn = true
            }
        }
    }
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSignedIn = false
    }
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = "A password reset link has been sent to your email."
            }
        }
    }
    func saveUserAnimalCount(animalName: String, count: Int) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        db.collection("users").document(user.uid).collection("animals").document(animalName).setData([
            "name": animalName,
            "count": count
        ]) { error in
            if let error = error {
                print("Error writing animal count: \(error)")
            }
        }
    }
    
    func getUserAnimals(grid: Grid) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        db.collection("users").document(user.uid).collection("animals").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error reading animals: \(error)")
            } else {
                var animals: [Animal] = []
                for document in querySnapshot!.documents {
                    let animalName = document.documentID
                    let count = document.get("count") as? Int ?? 0
                    for _ in 0..<count {
                        do {
                            let animal = try AnimalFactory.getAnimal(name: animalName, grid: grid)
                            animals.append(animal)
                        } catch {
                            print("Error creating animal: \(error)")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.userAnimals = animals
                }
            }
        }
    }
    func getFriendAnimals(for friendID: String, grid: Grid) {
        db.collection("users").document(friendID).collection("animals").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error reading animals: \(error)")
            } else {
                var animals: [Animal] = []
                for document in querySnapshot!.documents {
                    let animalName = document.documentID
                    let count = document.get("count") as? Int ?? 0
                    for _ in 0..<count {
                        do {
                            let animal = try AnimalFactory.getAnimal(name: animalName, grid: grid)
                            animals.append(animal)
                        } catch {
                            print("Error creating animal: \(error)")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.friendAnimals = animals // Assuming you have defined `friendAnimals` somewhere in the class
                }
            }
        }
    }
    
    func saveStudySessionData(duration: Int, date: Date) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let studySessionData: [String: Any] = [
            "duration": duration,
            "date": date
        ]
        
        db.collection("users").document(user.uid).collection("studySessions").addDocument(data: studySessionData) { error in
            if let error = error {
                print("Error writing study session data: \(error)")
            }
        }
    }
    
    func getStudySessionData(interval: Interval, completion: @escaping ([String: Double]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        var startDate: Date
        switch interval {
        case .day:
            startDate = Calendar.current.startOfDay(for: Date())
        case .week:
            startDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        case .month:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        case .year:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        }
        
        db.collection("users").document(user.uid).collection("studySessions").whereField("date", isGreaterThanOrEqualTo: startDate).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error reading study session data: \(error)")
            } else {
                var chartData: [String: Double] = [:]
                for document in querySnapshot!.documents {
                    let duration = document.get("duration") as? Int ?? 0
                    let date = document.get("date") as? Date ?? Date()
                    let intervalKey: String
                    switch interval {
                    case .day:
                        intervalKey = String(Calendar.current.component(.hour, from: date))
                    case .week:
                        intervalKey = DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
                    case .month, .year:
                        intervalKey = String(Calendar.current.component(.day, from: date))
                    }
                    if let existingDuration = chartData[intervalKey] {
                        chartData[intervalKey] = existingDuration + Double(duration) / 60 // convert seconds to minutes
                    } else {
                        chartData[intervalKey] = Double(duration) / 60 // convert seconds to minutes
                    }
                }
                completion(chartData)
            }
        }
    }
    func sendFriendRequest(toEmail email: String) {
        // Find the recipient user document by their email
        guard let currentUserEmail = Auth.auth().currentUser?.email,
              currentUserEmail.lowercased() != email.lowercased() else {
            print("User cannot send a friend request to themselves")
            return
        }
        self.db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user: \(error)")
            } else if let recipientUserId = querySnapshot?.documents.first?.documentID,
                      let senderUserId = Auth.auth().currentUser?.uid {
                // Add a friend request to the recipient's friendRequests collection
                self.db.collection("users").document(recipientUserId).collection("friendRequests").document(senderUserId).setData([:]) { error in
                    if let error = error {
                        print("Error sending friend request: \(error)")
                    }
                }
            }
        }
    }
    func fetchFriendRequests() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        self.friendRequests = []  // Clear the friend requests array

        db.collection("users").document(userId).collection("friendRequests").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching friend requests: \(error)")
            } else {
                let friendRequestIDs = querySnapshot?.documents.compactMap { $0.documentID } ?? []
                self.fetchUsersFromIDs(ids: friendRequestIDs, updatingFriends: false)
            }
        }
    }


    private func fetchUsersFromIDs(ids: [String], updatingFriends: Bool) {
        for id in ids {
            db.collection("users").document(id).getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data(),
                   let email = data["email"] as? String {
                    DispatchQueue.main.async {
                        if updatingFriends {
                            self.friends.append(User(id: id, email: email))
                        } else {
                            self.friendRequests.append(User(id: id, email: email))
                        }
                    }
                } else if let error = error {
                    print("Error fetching user: \(error)")
                }
            }
        }
    }

    
    
    
    func acceptFriendRequest(fromUserId userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Accept the friend request by adding each user to the other's friends collection
        let currentUserDoc = db.collection("users").document(currentUserId)
        let otherUserDoc = db.collection("users").document(userId)

        currentUserDoc.collection("friends").document(userId).setData([:]) { error in
            if let error = error {
                print("Error adding friend: \(error)")
            } else {
                otherUserDoc.collection("friends").document(currentUserId).setData([:]) { error in
                    if let error = error {
                        print("Error adding friend: \(error)")
                    } else {
                        // Remove the friend request from current user
                        currentUserDoc.collection("friendRequests").document(userId).delete { error in
                            if let error = error {
                                print("Error deleting friend request from current user: \(error)")
                            } else {
                                // Remove the friend request from other user
                                otherUserDoc.collection("friendRequests").document(currentUserId).delete { error in
                                    if let error = error {
                                        print("Error deleting friend request from other user: \(error)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    func declineFriendRequest(fromUserId userId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }

        // Decline the friend request by removing it from the friendRequests collection
        db.collection("users").document(currentUserId).collection("friendRequests").document(userId).delete { error in
            if let error = error {
                print("Error declining friend request: \(error)")
            }
        }
    }

    
    func fetchFriends() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        self.friends = []  // Clear the friends array

        let friendsRef = db.collection("users").document(userId).collection("friends")

        friendsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching friends: \(error)")
            } else if let snapshot = snapshot {
                // Get friend IDs from the documents
                let friendIDs = snapshot.documents.map { $0.documentID }

                // Fetch user details from the IDs
                self.fetchUsersFromIDs(ids: friendIDs, updatingFriends: true)
            }
        }
    }



    
    
    
    }
    

struct StudySession {
    var duration: Int  // duration of a study session in minutes
    var date: Date  // date when the study session occurred
}

enum Interval {
    case day, week, month, year
}
    
struct User: Identifiable {
    var id: String
    var email: String
}
    
    


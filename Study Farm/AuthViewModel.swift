//
//  AuthViewModel.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/20/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift



class AuthViewModel: ObservableObject {
    var studySessions: [StudySession] = []
    @Published var isSignedIn = false
    @Published var errorMessage = ""
    @Published var userAnimals: [Animal] = []
    //@Published var Tasks: [String] = []
    @Published var tasks: [Task] = []
    @Published var currentUserID = Auth.auth().currentUser

    @Published var friendAnimals: [Animal] = []
    //@Published var friendRequests: [String] = []
    @Published var userAnimalCounts: [(name: String, count: Int)] = []
    @Published var friendRequests: [User] = []
    @Published var friends: [User] = []
    @Published var sellAnimalError: String = ""
    @Published var username: String? // to hold the current user's username
    @Published var timerIsActive: Bool = false
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
   /* func savetask() {
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        let docRef = db.collection("")
    }*/
    // Fetch tasks from Firestore
    func fetchTasks() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        db.collection("users").document(user.uid).collection("tasks").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting tasks: \(err)")
            } else {
                self.tasks = querySnapshot!.documents.compactMap({ (document) -> Task? in
                    try? document.data(as: Task.self)
                })
            }
        }
    }
    func updateTimeForTask(task: Task, startTime: Date, endTime: Date) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        guard let taskId = task.id else { return }

        let db = Firestore.firestore()
        let taskDocument = db.collection("users").document(user.uid).collection("tasks").document(taskId)
        
        // Getting a reference to the 'studyIntervals' sub-collection and generating a new document ID
        let newIntervalRef = taskDocument.collection("studyIntervals").document()
        
        newIntervalRef.setData([
            "startTime": startTime.timeIntervalSince1970,
            "endTime": endTime.timeIntervalSince1970,
            "date": Date().timeIntervalSince1970
        ]) { err in
            if let err = err {
                print("Error adding study interval: \(err)")
            } else {
                print("Study interval successfully added!")
            }
        }
    }

    /*func editTaskTime(_ tasktime: Int) {
        db.collection("users").document(user.uid).collection("tasks").addFiel
        
    }*/
    
    // Add new task to Firestore
    func addTask(title: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let newTask = Task(title: title, status: false)
        
        do {
            let _ = try db.collection("users").document(user.uid).collection("tasks").addDocument(from: newTask)
        } catch let error {
            print("Error writing task to Firestore: \(error)")
        }
    }

    // Delete task from Firestore
    func deleteTask(task: Task) {
        guard let user = Auth.auth().currentUser, let taskId = task.id else {
            return
        }
        
        db.collection("users").document(user.uid).collection("tasks").document(taskId).delete() { err in
            if let err = err {
                print("Error removing task: \(err)")
            } else {
                self.fetchTasks()
            }
        }
    }

    // Update task status
    func updateTask(task: Task) {
        guard let user = Auth.auth().currentUser, let taskId = task.id else {
            return
        }
        
        let docRef = db.collection("users").document(user.uid).collection("tasks").document(taskId)
        
        docRef.updateData([
            "status": task.status
        ]) { err in
            if let err = err {
                print("Error updating task: \(err)")
            }
        }
    }

    func getUsername() {
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            let docRef = db.collection("users").document(userId)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.username = data?["username"] as? String
                } else {
                    print("Document does not exist")
                }
            }
        }
    func updateUsername(newUsername: String, completion: @escaping (Error?) -> Void) {
           // Check if the username already exists in the database
           db.collection("users")
               .whereField("username", isEqualTo: newUsername)
               .getDocuments() { (querySnapshot, err) in
                   if let err = err {
                       print("Error getting documents: \(err)")
                       completion(err)
                   } else if querySnapshot?.documents.count != 0 {
                       // Username already exists
                       completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Username already exists"]))
                   } else {
                       // Username does not exist, so we can update the username
                       guard let userId = Auth.auth().currentUser?.uid else {
                           return
                       }
                       self.db.collection("users").document(userId).updateData(["username": newUsername]) { error in
                           if let error = error {
                               print("Error updating username: \(error)")
                           }
                           completion(error)
                       }
                   }
           }
       }
   
    /*func fetchTasks() {
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            db.collection("users").document(user.uid).collection("tasks").getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting tasks: \(err)")
                } else {
                    self.tasks = querySnapshot!.documents.compactMap({ (document) -> Task? in
                        return try? document.data(as: Task.self)
                    })
                }
            }
        }
        
        func addTask(title: String) {
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            let newTask = Task(title: title)
            
            do {
                let _ = try db.collection("users").document(user.uid).collection("tasks").addDocument(from: newTask)
            } catch let error {
                print("Error writing task to Firestore: \(error)")
            }
        }
        
        func deleteTask(at index: Int) {
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            let task = tasks[index]
            db.collection("users").document(user.uid).collection("tasks").document(task.id!).delete() { err in
                if let err = err {
                    print("Error removing task: \(err)")
                } else {
                    fetchTasks()
                }
            }
        }*/

        func saveStudySessionDataWithTask(duration: Int, date: Date, task: Task) {
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            let studySessionData: [String: Any] = [
                "duration": duration,
                "date": date,
                "task": task.title
            ]
            
            db.collection("users").document(user.uid).collection("studySessions").addDocument(data: studySessionData) { error in
                if let error = error {
                    print("Error writing study session data: \(error)")
                }
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
    
    func createAccount(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(error)
                return
            }

            // User successfully created, now add email and username to Firestore
            let userId = result!.user.uid
            let lowercasedEmail = email.lowercased()
            self.db.collection("users").document(userId).setData([
                "email": lowercasedEmail,
                "username": lowercasedEmail
            ]) { error in
                if let error = error {
                    print("Error adding email and username to Firestore: \(error)")
                    completion(error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
                completion(nil)
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
    func sendFriendRequest(toEmail email: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserEmail = Auth.auth().currentUser?.email,
              currentUserEmail.lowercased() != email.lowercased() else {
            print("User cannot send a friend request to themselves")
            return
        }
        self.db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user: \(error)")
                completion(false)
            } else if let recipientUserId = querySnapshot?.documents.first?.documentID,
                      let senderUserId = Auth.auth().currentUser?.uid {
                self.db.collection("users").document(recipientUserId).collection("friendRequests").document(senderUserId).setData([:]) { error in
                    if let error = error {
                        print("Error sending friend request: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else {
                completion(false)
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
                   let username = data["username"] as? String {
                    DispatchQueue.main.async {
                        if updatingFriends {
                            self.friends.append(User(id: id, email: username))
                        } else {
                            self.friendRequests.append(User(id: id, email: username))
                        }
                    }
                } else if let error = error {
                    print("Error fetching user: \(error)")
                }
            }
        }
    }
    func deleteFriend(friend: User) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Removing friend from the current user's friends collection
        db.collection("users").document(userID).collection("friends").document(friend.id).delete { err in
            if let err = err {
                print("Error removing friend from current user's friends collection: \(err)")
            } else {
                print("Friend successfully removed from current user's friends collection!")
            }
        }

        // Removing the current user from the friend's friends collection
        db.collection("users").document(friend.id).collection("friends").document(userID).delete { err in
            if let err = err {
                print("Error removing current user from friend's friends collection: \(err)")
            } else {
                print("Current user successfully removed from friend's friends collection!")
            }
        }

        // Deleting friend from the current user's friend list in users document
        db.collection("users").document(userID).updateData([
            "friends": FieldValue.arrayRemove([friend.id])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                // Remove friend from local friends array
                self.friends = self.friends.filter { $0.id != friend.id }
                print("Friend successfully removed!")
            }
        }

        // Deleting the current user from the friend's friend list in users document
        db.collection("users").document(friend.id).updateData([
            "friends": FieldValue.arrayRemove([userID])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("User successfully removed from friend's list!")
            }
        }
    }


    func sellAnimal(animalName: String, quantity: Int, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        let animalDocument = db.collection("users").document(user.uid).collection("animals").document(animalName)

        animalDocument.getDocument { (document, error) in
            if let error = error {
                print("Error getting animal count: \(error)")
                completion(false)
            } else {
                var currentCount = document?.get("count") as? Int ?? 0
                if currentCount >= quantity {
                    currentCount -= quantity
                    animalDocument.setData([
                        "name": animalName,
                        "count": currentCount
                    ]) { error in
                        if let error = error {
                            print("Error writing animal count: \(error)")
                            completion(false)
                        } else {
                            // Update user's currency
                            let sellPrice = 10 * quantity
                            self.getUserCurrency { userCurrency in
                                let updatedCurrency = userCurrency + sellPrice
                                self.saveUserCurrency(updatedCurrency)
                                completion(true)
                            }
                        }
                    }
                } else {
                    print("Not enough animals to sell")
                    completion(false)
                }
            }
        }
    }

    func getUserAnimalCounts() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        db.collection("users").document(user.uid).collection("animals").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error reading animals: \(error)")
            } else {
                print("Query Snapshot: \(String(describing: querySnapshot))")
                var animalCounts: [(name: String, count: Int)] = []
                for document in querySnapshot!.documents {
                    let animalName = document.documentID
                    let count = document.get("count") as? Int ?? 0
                    animalCounts.append((name: animalName, count: count))
                }
                DispatchQueue.main.async {
                    self.userAnimalCounts = animalCounts
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
    
struct Task: Codable, Identifiable {
    @DocumentID var id: String?
    var title: String
    var status: Bool
}
           


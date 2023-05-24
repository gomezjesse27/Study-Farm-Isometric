//
//  AuthViewModel.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/20/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum TimeRange: String, CaseIterable {
    case today
    case week
    case month
    case year
}

struct StudySession {
    let subject: String
    let duration: Double
    let endTime: Date
}
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let value: Double
    let label: String
}

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage = ""
    @Published var userAnimals: [Animal] = []
    @Published var subjects: [String] = [] // Add this line
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
        fetchSubjects()
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
            guard result != nil, error == nil else {
                // An error occurred
                return
            }
            DispatchQueue.main.async {
                self.isSignedIn = true
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
                        var animal = AnimalFactory.getAnimal(name: animalName, grid: grid)
                        animals.append(animal)
                    }
                }
                DispatchQueue.main.async {
                    self.userAnimals = animals
                }
            }
        }
    }
    
    
    
    // Updated methods to handle local subject storage
    func getUserSubjects(completion: @escaping ([String]) -> Void) {
        let subjects = UserDefaults.standard.stringArray(forKey: "subjects") ?? []
        completion(subjects)
    }
    func createSubject(name: String) {
        var subjects = UserDefaults.standard.stringArray(forKey: "subjects") ?? []
        subjects.append(name)
        UserDefaults.standard.setValue(subjects, forKey: "subjects")
        fetchSubjects()
    }
    
    func deleteSubject(name: String) {
        var subjects = UserDefaults.standard.stringArray(forKey: "subjects") ?? []
        subjects.removeAll(where: { $0 == name })
        UserDefaults.standard.setValue(subjects, forKey: "subjects")
        fetchSubjects()
    }
    
    func fetchSubjects() {
        getUserSubjects { (retrievedSubjects) in
            DispatchQueue.main.async {
                self.subjects = retrievedSubjects
            }
        }
    }
        func saveStudySession(subject: String, duration: Double) {
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            let studySession: [String: Any] = [
                "subject": subject,
                "duration": duration,
                "endTime": Date().timeIntervalSince1970  // UNIX timestamp
            ]
            
            db.collection("users").document(user.uid).collection("studySessions").addDocument(data: studySession) { error in
                if let error = error {
                    print("Error writing study session: \(error)")
                }
            }
        }
        func getStudySessions(completion: @escaping ([StudySession]) -> Void) {
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            db.collection("users").document(user.uid).collection("studySessions").order(by: "endTime").getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error reading study sessions: \(error)")
                } else {
                    var studySessions: [StudySession] = []
                    
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        if let subject = data["subject"] as? String,
                           let duration = data["duration"] as? Double,
                           let endTime = data["endTime"] as? TimeInterval {
                            let studySession = StudySession(subject: subject, duration: duration, endTime: Date(timeIntervalSince1970: endTime))
                            studySessions.append(studySession)
                        }
                    }
                    
                    completion(studySessions)
                }
            }
        }
        func getStudySessionData(timeRange: TimeRange, completion: @escaping ([ChartDataPoint]) -> Void) {
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            let (start, end) = timeRangeBoundaries(timeRange)
            
            db.collection("users").document(user.uid).collection("studySessions")
                .whereField("endTime", isGreaterThanOrEqualTo: start)
                .whereField("endTime", isLessThanOrEqualTo: end)
                .order(by: "endTime")
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error reading study sessions: \(error)")
                    } else {
                        var chartDataPoints: [ChartDataPoint] = []
                        
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            
                            if let subject = data["subject"] as? String,
                               let duration = data["duration"] as? Double,
                               let endTime = data["endTime"] as? TimeInterval {
                                let date = Date(timeIntervalSince1970: endTime)
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                let dateString = dateFormatter.string(from: date)
                                let dataPoint = ChartDataPoint(value: duration, label: dateString)
                                chartDataPoints.append(dataPoint)
                            }
                        }
                        
                        completion(chartDataPoints)
                    }
                }
        }
        
    func getSubjectData(timeRange: TimeRange, completion: @escaping ([ChartDataPoint]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let (start, end) = timeRangeBoundaries(timeRange)
        
        db.collection("users").document(user.uid).collection("studySessions")
            .whereField("endTime", isGreaterThanOrEqualTo: start)
            .whereField("endTime", isLessThanOrEqualTo: end)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting study sessions: \(error)")
                } else {
                    var subjectDurationDict: [String: Double] = [:]
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let subject = data["subject"] as? String,
                           let duration = data["duration"] as? Double {
                            subjectDurationDict[subject, default: 0] += duration
                        }
                    }
                    
                    var chartDataPoints: [ChartDataPoint] = []
                    for (subject, duration) in subjectDurationDict {
                        let dataPoint = ChartDataPoint(value: duration, label: subject)
                        chartDataPoints.append(dataPoint)
                    }
                    completion(chartDataPoints)
                }
            }
        
    }
        
        func timeRangeBoundaries(_ range: TimeRange) -> (TimeInterval, TimeInterval) {
            let now = Date()
            var components: DateComponents?
            
            switch range {
            case .today:
                components = DateComponents(day: -1)
            case .week:
                components = DateComponents(weekOfYear: -1)
            case .month:
                components = DateComponents(month: -1)
            case .year:
                components = DateComponents(year: -1)
            }
            
            let start = Calendar.current.date(byAdding: components!, to: now)!.timeIntervalSince1970
            let end = now.timeIntervalSince1970
            
            return (start, end)
        }
        
    }
    
    
    
    
    


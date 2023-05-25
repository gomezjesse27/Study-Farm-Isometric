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
    
    
        
        
    }
    
    
    
    
    


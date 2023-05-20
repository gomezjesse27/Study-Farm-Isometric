//
//  AuthViewModel.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/20/23.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage = ""
    

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
    
}



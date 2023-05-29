//
//  CreateAccountView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/20/23.
//
import Foundation
import SwiftUI
struct CreateAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = "" // to hold the error message
    
    var body: some View {
        ZStack{
            Color(red: 188/255, green: 224/255, blue: 247/255)
                        .edgesIgnoringSafeArea(.all)  // This makes the color fill the entire screen

        VStack {
            Text("Email")
                .foregroundColor(.white)
            TextField("", text: $email)
                .padding()
                .foregroundColor(.black)
                .background(Color(white: 0.9))
                .cornerRadius(5)
            
            Text("Password")
                .foregroundColor(.white)
            SecureField("", text: $password)
                .padding()
                .foregroundColor(.black)
                .background(Color(white: 0.9))
                .cornerRadius(5)
            
            Text("Password must be at least 8 characters, and contain at least one number and one uppercase letter.")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Text("Confirm Password")
                .foregroundColor(.white)
            SecureField("", text: $confirmPassword)
                .padding()
                .foregroundColor(.black)
                .background(Color(white: 0.9))
                .cornerRadius(5)
            
            Text(errorMessage) // Display the error message
                .foregroundColor(.red)
                .padding()
            
            Button(action: {
                if password == confirmPassword {
                    if self.isValidPassword(testStr: password) {
                        authViewModel.createAccount(email: email, password: password) { (error) in
                            if let error = error {
                                errorMessage = error.localizedDescription
                            } else {
                                errorMessage = ""
                            }
                        }
                    } else {
                        errorMessage = "Password does not meet requirements"
                    }
                } else {
                    errorMessage = "Passwords do not match"
                }
            }) {
                Text("Create Account")
                    .padding()
                    .background(Color(red: 186/255, green: 233/255, blue: 217/255))
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .background(Color(red: 188/255, green: 224/255, blue: 247/255))
    }
}

    // Validate the password
    func isValidPassword(testStr: String) -> Bool {
        // Password must be at least 8 characters, and contain at least one number and one uppercase letter
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$")
        return passwordTest.evaluate(with: testStr)
    }
}




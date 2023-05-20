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

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .foregroundColor(.black)
                .background(Color(white: 0.9))
                .cornerRadius(5)

            SecureField("Password", text: $password)
                .padding()
                .foregroundColor(.black)
                .background(Color(white: 0.9))
                .cornerRadius(5)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .foregroundColor(.black)
                .background(Color(white: 0.9))
                .cornerRadius(5)

            Button(action: {
                if password == confirmPassword {
                    authViewModel.createAccount(email: email, password: password)
                }
            }) {
                Text("Create Account")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
        }
        .padding()
    }
}

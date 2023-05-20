//
//  LoginView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/20/23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showPasswordResetView = false
    @State private var showCreateAccountView = false

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .border(Color.gray)
            
            SecureField("Password", text: $password)
                .padding()
                .border(Color.gray)
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                authViewModel.signIn(email: email, password: password)
            }) {
                Text("Log In")
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            
            Button(action: {
                self.showPasswordResetView = true
            }) {
                Text("Forgot Password?")
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            
            Button(action: {
                self.showCreateAccountView = true
            }) {
                Text("Create Account")
            }
            
            .sheet(isPresented: $showPasswordResetView) {
                PasswordResetView(showPasswordResetView: $showPasswordResetView)
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showCreateAccountView) {
                            CreateAccountView()
                                .environmentObject(authViewModel)
                        }
        }
        .padding()
    }
}

struct PasswordResetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showPasswordResetView: Bool
    @State private var email = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .border(Color.gray)
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                authViewModel.resetPassword(email: email)
            }) {
                Text("Reset Password")
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            
            Button(action: {
                self.showPasswordResetView = false
            }) {
                Text("Cancel")
            }
        }
        .padding()
    }
}

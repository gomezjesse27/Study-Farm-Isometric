//
//  Study_FarmApp.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/19/23.
//

import SwiftUI
import Firebase

@main
struct Study_FarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        @StateObject var authViewModel = AuthViewModel()
        
        var body: some Scene {
            WindowGroup {
                if authViewModel.isSignedIn {
                    // If a user is signed in, show the main app view.
                    ContentView()
                        .environmentObject(authViewModel)
                } else {
                    // If no user is signed in, show the login view.
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }


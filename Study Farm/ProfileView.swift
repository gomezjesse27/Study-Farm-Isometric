//
//  ProfileView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//

import SwiftUI
import SwiftUICharts

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]  // Add more if needed
    
    var body: some View {
        ScrollView {
            VStack {
                
                // Your existing sign-out button code...
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                }
            }
            
        }
        
    }
    
    
}


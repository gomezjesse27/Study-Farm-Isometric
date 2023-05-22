//
//  ProfileView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//

//
//  ProfileView.swift
//  Study Farm
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            Text("Profile View Placeholder")
            
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

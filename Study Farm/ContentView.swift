//
//  ContentView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/19/23.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            // The main content
            VStack {
                switch selectedTab {
                case 0:
                    TimerView()
                case 1:
                    FriendsView()
                case 2:
                    FarmView()
                case 3:
                    ShopView()
                case 4:
                    ProfileView()
                default:
                    EmptyView()
                }
                Spacer() // Pushes the tab bar to the bottom
            }
            
            // Custom Tab Bar
            VStack {
                Spacer() // Pushes the tab bar to the bottom
                HStack {
                    Button(action: { selectedTab = 0 }) {
                        VStack {
                            Image("hourglass")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 30) // Adjust the frame as needed                        }
                        }
                        .padding([.horizontal, .bottom]) // Add horizontal and bottom padding to the buttons
                        
                        Button(action: { selectedTab = 1 }) {
                            VStack {
                                Image("support")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 30) // Adjust the frame as needed
                            }
                        }
                        .padding([.horizontal, .bottom])
                        
                        Button(action: { selectedTab = 2 }) {
                            VStack {
                                Image("livestock")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 30) // Adjust the frame as needed
                                
                            }
                        }
                        .padding([.horizontal, .bottom])
                        
                        Button(action: { selectedTab = 3 }) {
                            VStack {
                                Image("farm-shop")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 30) // Adjust the frame as needed
                            }
                        }
                        .padding([.horizontal, .bottom])
                        
                        Button(action: { selectedTab = 4 }) {
                            VStack {
                                Image("farmer")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30) // Adjust the frame as needed
                            }
                        }
                        .padding([.horizontal, .bottom])
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 60) // Set tab bar width to match screen width and fixed height
                    .background(Color(red: 168/255, green: 213/255, blue: 247/255)) // You can customize this as needed
                }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}

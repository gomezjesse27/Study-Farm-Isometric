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
    init() {
            UITabBar.appearance().barTintColor = UIColor.systemBackground
            UITabBar.appearance().isTranslucent = false
        }
    var body: some View {
        ZStack {
            Color(red: 0.690, green: 0.878, blue: 0.902).edgesIgnoringSafeArea(.all)

            Rectangle()
                .foregroundColor(Color.white)
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                TimerView()
                    .tabItem {
                        Image(systemName: "timer")
                        Text("Timer")
                    }
                    .tag(0)

                FriendsView()
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Friends")
                    }
                    .tag(1)

                FarmView()
                    .tabItem {
                        Image(systemName: "leaf")
                        Text("Farm")
                    }
                    .tag(2)

                ShopView()
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Shop")
                    }
                    .tag(3)

                ProfileView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(4)
            }
            .environmentObject(authViewModel)
            .accentColor(.blue) // Adjust this color as needed.
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}

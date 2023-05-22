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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}

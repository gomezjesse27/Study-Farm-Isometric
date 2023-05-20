//
//  ContentView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/19/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

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

            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Analytics")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TimerView: View {
    @State private var secondsRemaining = 7200.0
    @State private var timerIsActive = false
    @State private var farmBucks = 0
    @State private var totalStudyTime = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Farm Bucks: \(farmBucks)")
                    .font(.headline)
                    .padding(.trailing)
            }
            .padding(.top)

            if timerIsActive {
                Text(formatTime(time: secondsRemaining))
                    .font(.largeTitle)
                    .padding(.bottom, 50)
            } else {
                VStack {
                    Text(formatTime(time: secondsRemaining))
                        .font(.largeTitle)
                    Slider(value: $secondsRemaining, in: 300...7200, step: 300)
                        .padding(.horizontal)
                }
            }
            
            HStack {
                Button(action: {
                    self.timerIsActive = true
                    self.totalStudyTime = self.secondsRemaining
                }) {
                    Text("Start Timer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                }
                
                Button(action: {
                    self.timerIsActive = false
                    self.secondsRemaining = 7200.0
                }) {
                    Text("Cancel Timer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                }
            }
        }
        .padding()
        .onReceive(timer) { _ in
            guard self.timerIsActive else { return }
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
            } else {
                self.timerIsActive = false
                self.secondsRemaining = self.totalStudyTime
                calculateBucks()
            }
        }
    }
    
    private func calculateBucks() {
        let minutes = Int(totalStudyTime) / 60
        switch minutes {
        case 1...19:
            farmBucks += 10
        case 20...39:
            farmBucks += 30
        default:
            farmBucks += 50
        }
    }
    
    private func formatTime(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}






struct FriendsView: View {
    var body: some View {
        Text("Friends View Placeholder")
    }
}

struct FarmView: View {
    var body: some View {
        Text("Farm View Placeholder")
    }
}

struct AnalyticsView: View {
    var body: some View {
        Text("Analytics View Placeholder")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile View Placeholder")
    }
}

//
//  TimerView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//


import Foundation
import SwiftUI

/*struct TimerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var secondsRemaining = 7200.0
    //@State private var timerIsActive = false
    @State private var farmBucks = 0
    @State private var totalStudyTime = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    

    var body: some View {
        ZStack {
            Color(red: 188/255, green: 224/255, blue: 247/255)
                    .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    Image("FarmBucks")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text("\(farmBucks)")
                        .font(.headline)
                        .padding(.trailing)
                }
                .padding(.top)

                VStack {
                    CustomSlider(secondsRemaining: $secondsRemaining)
                        .disabled( self.authViewModel.timerIsActive)
                }

                HStack {
                    if !self.authViewModel.timerIsActive {
                        Button(action: {
                            self.authViewModel.timerIsActive = true
                            self.totalStudyTime = self.secondsRemaining
                        }) {
                            Text("Start Studying")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(red: 186/255, green: 233/255, blue: 217/255))
                                .cornerRadius(15)
                        }
                    } else {
                        Button(action: {
                            self.authViewModel.timerIsActive = false
                            self.secondsRemaining = self.totalStudyTime
                        }) {
                            Text("Cancel Session")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(15)
                        }
                    }
                }
            }
            .padding()
            .onReceive(timer) { _ in
                guard self.authViewModel.timerIsActive else { return }
                if self.secondsRemaining > 0 {
                    self.secondsRemaining -= 1
                } else {
                    self.authViewModel.timerIsActive = false
                    self.secondsRemaining = self.totalStudyTime
                    calculateBucks()
                    authViewModel.saveUserCurrency(farmBucks) // Saving currency only when timer stops
                    authViewModel.saveStudySessionData(duration: Int(totalStudyTime), date: Date()) // Save study session data
                }
            }
            .onAppear {
                authViewModel.getUserCurrency { (currency) in
                    self.farmBucks = currency
                }
            }
        }
    }
    
    private func calculateBucks() {
        let minutes = Int(totalStudyTime) / 60
        switch minutes {
        case 5...19:
            farmBucks += 10
        case 20...39:
            farmBucks += 25
        case 40...59:
            farmBucks += 40
        case 60...79:
            farmBucks += 60
        case 80...99:
            farmBucks += 60
        case 100...120:
            farmBucks += 60
        default:
            farmBucks += 50
        }
    }


    
    private func formatTime(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}*/


struct CustomSlider: View {
    @Binding var secondsRemaining: Double
    let ringDiameter = 300.0
    @State var rotationAngle = Angle(degrees: 0)
    let stepSize = 5.0/120.0  // 5 minutes steps on 2 hours scale

    private func changeAngle(location: CGPoint) -> Angle {
        // Create a Vector for the location (reversing the y-coordinate system on iOS)
        let vector = CGVector(dx: location.x, dy: -location.y)
        
        // Calculate the angle of the vector
        let angleRadians = atan2(vector.dx, vector.dy)
        
        // Convert the angle to a range from 0 to 360 (rather than having negative angles)
        let positiveAngle = angleRadians < 0.0 ? angleRadians + (2.0 * .pi) : angleRadians
        
        // Calculate the raw progress value based on angle
        var rawProgress = positiveAngle / (2.0 * .pi)
        
        // Adjust the progress value to account for the step size
        let modValue = rawProgress.truncatingRemainder(dividingBy: stepSize)
        if modValue < stepSize / 2 {
            rawProgress -= modValue
        } else {
            rawProgress += stepSize - modValue
        }

        // Update secondsRemaining value
        secondsRemaining = rawProgress * 120.0 * 60.0  // 120 minutes times 60 seconds per minute

        return Angle(radians: Double(rawProgress) * 2.0 * .pi)
    }
    
    var body: some View {
        let progress = secondsRemaining / (120.0 * 60.0)
        let minutes = Int((secondsRemaining + 0.5) / 60.0)
        let seconds = Int((secondsRemaining + 0.5).truncatingRemainder(dividingBy: 60.0))

        ZStack {
                   VStack {
                       ZStack {
                           Circle()
                               .stroke(Color(hue: 0.0, saturation: 0.0, brightness: 0.9), lineWidth: 20.0)
                               .overlay() {
                                   Text(String(format: "%02d:%02d", minutes, seconds)) // Display the actual time
                                       .font(.system(size: 50))  // Adjust font size here
                                       .fontWeight(.bold) // Make the font bold for more 'bubbly' effect
                                       .padding(5) // Add some padding around the text
                                       /*.overlay( // Create an overlay around the text
                                           RoundedRectangle(cornerRadius: 10) // Set the shape of the overlay
                                               .stroke(Color.black, lineWidth: 3) // Set the overlay's color and line width*/
                                       

                               }
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(Color(hue: 0.0, saturation: 0.5, brightness: 0.9),
                                style: StrokeStyle(lineWidth: 20.0, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                           Circle()
                                                  .fill(Color.white)
                                                  .shadow(radius: 3)
                                                  .frame(width: 21, height: 21)
                                                  .offset(y: -CGFloat(ringDiameter) / 2.0)
                                                  .rotationEffect(rotationAngle)
                                                  .gesture(
                                                      DragGesture(minimumDistance: 0.0)
                                                          .onChanged() { value in
                                                              rotationAngle = changeAngle(location: value.location)
                                                          }
                                                  )
                                          }
                                          .frame(width: CGFloat(ringDiameter), height: CGFloat(ringDiameter))

                
                
            }
            .padding(.vertical, 10)
        }
    }
}



struct TimerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var secondsRemaining = 7200.0
    @State private var farmBucks = 0
    @State private var totalStudyTime = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Added state for keeping track of current tab view
    @State private var currentTab: Tab = .timer

    enum Tab {
        case timer
        case tasks
        case calendar  // Placeholder for new view
    }

    var body: some View {
        ZStack {
            Color(red: 188/255, green: 224/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Tab view selection
                HStack {
                    Button(action: {
                        currentTab = .timer
                    }) {
                        Text("Timer")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .fontWeight(currentTab == .timer ? .bold : .none)
                            .underline(currentTab == .timer, color: Color.white)
                    }
                    Spacer()
                    Button(action: {
                        currentTab = .tasks
                    }) {
                        Text("Tasks")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .fontWeight(currentTab == .tasks ? .bold : .none)
                            .underline(currentTab == .tasks, color: Color.white)
                    }
                    Spacer()
                    Button(action: {
                        currentTab = .calendar
                    }) {
                        Text("Calendar")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .fontWeight(currentTab == .calendar ? .bold : .none)
                            .underline(currentTab == .calendar, color: Color.white)
                    }
                }.padding()
                
                // Added tab view
                TabView(selection: $currentTab) {
                    // Timer View (Current View)
                    
                    ZStack {
                        Color(red: 188/255, green: 224/255, blue: 247/255)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Image("FarmBucks")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text("\(farmBucks)")
                                    .font(.headline)
                                    .padding(.trailing)
                            }
                            .padding(.top)
                            
                            VStack {
                                CustomSlider(secondsRemaining: $secondsRemaining)
                                    .disabled( self.authViewModel.timerIsActive)
                            }
                            
                            HStack {
                                if !self.authViewModel.timerIsActive {
                                    Button(action: {
                                        self.authViewModel.timerIsActive = true
                                        self.totalStudyTime = self.secondsRemaining
                                    }) {
                                        Text("Start Studying")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color(red: 186/255, green: 233/255, blue: 217/255))
                                            .cornerRadius(15)
                                    }
                                } else {
                                    Button(action: {
                                        self.authViewModel.timerIsActive = false
                                        self.secondsRemaining = self.totalStudyTime
                                    }) {
                                        Text("Cancel Session")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.red)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        .padding()
                        .onReceive(timer) { _ in
                            guard self.authViewModel.timerIsActive else { return }
                            if self.secondsRemaining > 0 {
                                self.secondsRemaining -= 1
                            } else {
                                self.authViewModel.timerIsActive = false
                                self.secondsRemaining = self.totalStudyTime
                                calculateBucks()
                                authViewModel.saveUserCurrency(farmBucks) // Saving currency only when timer stops
                                authViewModel.saveStudySessionData(duration: Int(totalStudyTime), date: Date()) // Save study session data
                            }
                        }
                        .onAppear {
                            authViewModel.getUserCurrency { (currency) in
                                self.farmBucks = currency
                            }
                        }
                    }
                    
                    .tag(Tab.timer)
                    
                    
                        // Tasks View
                        TasksView()
                            .tag(Tab.tasks)
                        
                        // ... your other views here ...
                        
                        // Calendar View
                        CalendarView()
                            .tag(Tab.calendar)
                    
                }
            }
        }
    }
private func calculateBucks() {
    let minutes = Int(totalStudyTime) / 60
    switch minutes {
    case 5...19:
        farmBucks += 10
    case 20...39:
        farmBucks += 25
    case 40...59:
        farmBucks += 40
    case 60...79:
        farmBucks += 60
    case 80...99:
        farmBucks += 60
    case 100...120:
        farmBucks += 60
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






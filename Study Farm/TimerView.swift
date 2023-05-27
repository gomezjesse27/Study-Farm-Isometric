//
//  TimerView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//
import Foundation
import SwiftUI
struct TimerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var secondsRemaining = 7200.0
    @State private var timerIsActive = false
    @State private var farmBucks = 0
    @State private var totalStudyTime = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    

    var body: some View {
        ZStack {
            Color(red: 188/255, green: 224/255, blue: 247/255)
                    .edgesIgnoringSafeArea(.all)
            /*Image("TimerViewBG") // Replace this with your background image name
                .resizable()
               .edgesIgnoringSafeArea(.all)*/
            VStack {
                HStack {
                    Spacer()
                    Image("FarmBucks") // Replace this with your FarmBucks image
                        .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    Text("\(farmBucks)")
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
                        CustomSlider(value: $secondsRemaining, range: 60...7200, step: 60)
                            .padding(.horizontal)
                    }
                }

                
                HStack {
                    if !timerIsActive {
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
                    } else {
                        Button(action: {
                            self.timerIsActive = false
                            self.secondsRemaining = self.totalStudyTime
                            // No more calculateBucks() or saveUserCurrency() here
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


struct CustomSliderKnob: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 30, height: 30)
            .shadow(radius: 2)
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green)
                    .frame(width: CGFloat((self.value - self.range.lowerBound) / (self.range.upperBound - self.range.lowerBound)) * geometry.size.width)
                CustomSliderKnob()
                    .offset(x: CGFloat((self.value - self.range.lowerBound) / (self.range.upperBound - self.range.lowerBound)) * geometry.size.width - 15)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                self.value = max(min(Double(gesture.location.x / geometry.size.width) * (self.range.upperBound - self.range.lowerBound) + self.range.lowerBound, self.range.upperBound), self.range.lowerBound)
                                self.value = round(self.value / self.step) * self.step
                            }
                    )
            }
        }
        .frame(height: 30)
    }
}






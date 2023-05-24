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
    @State private var studySessionData: [ChartDataPoint] = []
    @State private var subjectData: [ChartDataPoint] = []
    @State private var selectedTimeRange = TimeRange.today
    let timeRanges = TimeRange.allCases
    
    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]  // Add more if needed

    var body: some View {
        ScrollView {
            VStack {
                Text("Select Time Range")
                    .font(.title2)
                Picker("Select Time Range", selection: $selectedTimeRange) {
                    ForEach(timeRanges, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                Text("Study Session Duration")
                    .font(.title2)
                LineChartView(data: studySessionData.map { $0.value }, title: "Study Session Duration", legend: "Daily Duration")
                    .padding()

                Text("Subject Distribution")
                    .font(.title2)
                PieChartView(data: subjectData.map { $0.value }, title: "Subject Distribution", legend: "Subject Hours")
                    .padding()

                // Legend
                VStack(alignment: .leading) {
                    ForEach(0..<subjectData.count) { index in
                        HStack {
                            Circle()
                                .fill(colors[index % colors.count])
                                .frame(width: 10, height: 10)
                            Text(subjectData[index].label)
                        }
                    }
                }
                .padding()

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
            .onAppear {
                loadStudyData()
            }
            .onChange(of: selectedTimeRange) { newValue in
                loadStudyData()
            }
        }
    }

    private func loadStudyData() {
        authViewModel.getStudySessionData(timeRange: selectedTimeRange) { data in
            studySessionData = data
        }
        authViewModel.getSubjectData(timeRange: selectedTimeRange) { data in
            subjectData = data
        }
    }
}


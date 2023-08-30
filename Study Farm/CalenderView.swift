//
//  CalenderView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 8/25/23.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    // To track which day we're on
    @State private var currentDate = Date()
    @ObservedObject private var viewModel = AuthViewModel()
    // Some kind of data structure to store tasks/events on a given day
    // For this example, I'll use a static list. You'll be fetching these from Firebase in reality
    @State private var tasksForTheDay: [TaskInterval] = []
    @State private var showingAddTask = false

    var body: some View {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Button(action: { moveDate(by: -1) }) {
                        Text("<-")
                    }
                    
                    Text(formatted(date: currentDate)) // Replaced "Placeholder" with the formatted date
                    if formatted(date: currentDate) != formatted(date: Date()){
                        Button(action: { moveDate(by: 1) }) {
                            Text("->")
                        }
                    }
                    Spacer()
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    }
                }
                .font(.headline)

            // List of hours
            ScrollView {
                ForEach(0..<24) { hour in
                    HStack {
                        Text("\(hour):00")
                            .frame(width: 60)
                        
                        // To show the task during this hour, if any
                        if let task = taskDuring(hour: hour) {
                            Text(formatted(date: currentDate))
                            Text(task.title)
                                
                                .background(Color.blue.opacity(0.2))
                                .frame(height: 40)
                        }
                        Spacer()
                    }
                }
            }
        }
        .onAppear(perform: {
            viewModel.fetchTasksFor(date: currentDate)
            
        })
    }
}

    
struct TaskInterval {
    var title: String
    var startHour: Int // starting from 0 to 23
    var endHour: Int // ending on 1 to 24
}
extension CalendarView {
    func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func moveDate(by days: Int) {
        let dayComponent = DateComponents(day: days)
        if let newDate = Calendar.current.date(byAdding: dayComponent, to: currentDate) {
            currentDate = newDate
            viewModel.tasksForTheDay = []
            viewModel.fetchTasksFor(date: currentDate)
        }
    }


    func taskDuring(hour: Int) -> TaskInterval? {
        return viewModel.tasksForTheDay.first(where: { $0.startHour <= hour && $0.endHour > hour })
    }
    
}

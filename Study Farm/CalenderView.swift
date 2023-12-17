import Foundation
import SwiftUI

struct CalendarView: View {
    // To track which day we're on
    @State private var currentDate = Date()
    @ObservedObject private var viewModel = AuthViewModel()
    
    @State private var showingAddTask = false

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                
                Button(action: { moveDate(by: -1) }) {
                    Text("<-")
                }
                
                Text(formatted(date: currentDate))
                if formatted(date: currentDate) != formatted(date: Date()) {
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

            ScrollView {
                GeometryReader { geo in
                    let hourHeight = geo.size.height / 24.0
                    
                    ForEach(viewModel.tasksForTheDay, id: \.title) { task in
                        let startOffset = (CGFloat(task.startHour) + CGFloat(task.startMinute) / 60.0) * hourHeight
                        let taskHeight = (CGFloat(task.endHour) + CGFloat(task.endMinute) / 60.0 - CGFloat(task.startHour) - CGFloat(task.startMinute) / 60.0) * hourHeight
                        
                        Button(action: {
                            // Handle task button tap here
                        }) {
                            Text(task.title)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .frame(height: taskHeight)
                        .offset(y: startOffset)
                    }
                }
                .frame(height: 24 * 60)  // 24 hours x 60 pixels per hour
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
    var startMinute: Int // from 0 to 59
    var endHour: Int // ending on 1 to 24
    var endMinute: Int // from 0 to 59
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
            viewModel.fetchTasksFor(date: currentDate)
        }
    }
}


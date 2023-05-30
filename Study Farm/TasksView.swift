import SwiftUI

struct TasksView: View {
    @State private var tasks: [String] = []
    @State private var showingAddTask = false
    @State private var newTask = ""
    @State private var taskStatuses: [Bool] = []

    var body: some View {
        ZStack {
            Color(red: 188/255, green: 224/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("Tasks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()

                    Spacer()

                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                    }
                    .padding()
                }

                ScrollView {
                    ForEach(tasks.indices, id: \.self) { index in
                        HStack {
                            Button(action: { taskStatuses[index].toggle() }) {
                                Image(systemName: taskStatuses[index] ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                            }

                            Text(tasks[index])
                                .strikethrough(taskStatuses[index], color: .white)
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Spacer()

                            Button(action: { deleteTask(at: index) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color(red: 168/255, green: 204/255, blue: 227/255)) // Darker blue background
                        .cornerRadius(10)
                        .padding(.bottom, 5)
                    }
                }

                .sheet(isPresented: $showingAddTask, content: {
                    VStack {
                        Text("New Task")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        TextField("Enter task", text: $newTask)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: {
                            if !newTask.isEmpty {
                                tasks.append(newTask)
                                taskStatuses.append(false)
                                newTask = ""
                            }
                            showingAddTask = false
                        }) {
                            Text("Add Task")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(red: 186/255, green: 233/255, blue: 217/255))
                                .cornerRadius(15)
                        }
                        .padding()
                    }
                })
            }
        }
    }
    
    private func deleteTask(at index: Int) {
        tasks.remove(at: index)
        taskStatuses.remove(at: index)
    }
}


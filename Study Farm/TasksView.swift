import SwiftUI

struct TasksView: View {
    @State private var showingAddTask = false
    @State private var showingEditTask = false
    @State private var newTask = ""
    @State private var startTime = Date.now
    @State private var endTime = Date.now
    @ObservedObject private var viewModel = AuthViewModel()
    @State private var currentEditingTask: Task?

    /*@State private var taskStatuses: [bool] = []*/


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
                    ForEach(viewModel.tasks) { task in
                        HStack {
                           /*Button(action: { viewModel.updateTask(task: task) }) {
                                Image(systemName: task.status ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                            }*/
                            
                            Button(action: {
                                currentEditingTask = task
                                showingEditTask = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                            }


                            Text(task.title)
                                .strikethrough(task.status, color: .white)
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Spacer()

                            Button(action: { viewModel.deleteTask(task: task) }) {
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
                                viewModel.addTask(title: newTask)
                                newTask = ""
                                viewModel.fetchTasks()
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
                
                .sheet(isPresented: $showingEditTask, content: {
                    VStack {
                        Text("Add Time")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        
                        
                        DatePicker("start time", selection: $startTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .padding()
                        DatePicker("end time", selection: $endTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .padding()
                        
                        
                        Button(action: {
                            if let editingTask = currentEditingTask, startTime < endTime {
                                // Ensure 'currentUserId' exists in 'AuthViewModel'.
                                // If it doesn't, you need to define or find the correct name for that property.
                                
                                    viewModel.updateTimeForTask( task: editingTask, startTime: startTime, endTime: endTime)
                                    showingEditTask = false
                                    currentEditingTask = nil // Clearing the current editing task
                                
                            } else {
                                // Display an error to the user, possibly using an alert.
                            }
                            showingAddTask = false
                        }) {
                            Text("Add Time")
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
        }.onAppear(perform: {
            viewModel.fetchTasks()
        })
    }
}

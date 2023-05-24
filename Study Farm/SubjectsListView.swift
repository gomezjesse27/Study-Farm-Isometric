

import SwiftUI

struct SubjectsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var subjects: [String] = []
    @State private var searchText = ""
    @State private var showAddSubjectModal = false

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    showAddSubjectModal = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showAddSubjectModal) {
                    SubjectCreationView()
                        .environmentObject(authViewModel)
                }
            }

            List {
                ForEach(subjects.filter { searchText.isEmpty ? true : $0.contains(searchText) }, id: \.self) { subject in
                    HStack {
                        Text(subject)
                        Spacer()
                        Button(action: {
                            authViewModel.deleteSubject(name: subject)
                            fetchSubjects()
                        }) {
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchSubjects()
        }
    }

    private func fetchSubjects() {
        authViewModel.getUserSubjects { (subjects) in
            self.subjects = subjects
        }
    }
}

struct SubjectCreationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var newSubjectName = ""

    var body: some View {
        VStack {
            TextField("Subject name", text: $newSubjectName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Button(action: {
                authViewModel.createSubject(name: newSubjectName)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Add")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.top, 20)
        }
    }
}


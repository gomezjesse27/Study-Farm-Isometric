//
//  FriendsView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//

import SwiftUI


struct FriendsView: View {
    @State private var searchText = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("TimerViewBG") // Replace this with your background image name
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack { // Extra VStack added here
                    SearchBar(text: $searchText, placeholder: "Search friends")
                    FriendsListView() // Use the new FriendsListView here
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 20) {
                        NavigationLink(destination: AddFriendView()) {
                            Image(systemName: "plus")
                        }
                        NavigationLink(destination: FriendRequestsView()) {
                            Image(systemName: "envelope")
                        }
                    }
                }
            }
            .onAppear {
                authViewModel.fetchFriends()
            }
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
    }
}
struct FriendsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack {
                ForEach(authViewModel.friends, id: \.id) { friend in
                    NavigationLink(destination: FriendsFarmView(friendID: friend.id, friendEmail: friend.email)) {
                        Text(friend.email)
                    }
                    Divider()  // Adding Divider to mimic List behavior
                }
            }
            .padding()  // Add padding to mimic List behavior
        }
    }
}


    struct FriendsView_Previews: PreviewProvider {
        static var previews: some View {
            FriendsView()
        }
    }
    
    struct SearchBar: UIViewRepresentable {
        
        @Binding var text: String
        var placeholder: String
        
        func makeUIView(context: Context) -> UISearchBar {
            let searchBar = UISearchBar(frame: .zero)
            searchBar.delegate = context.coordinator
            searchBar.placeholder = placeholder
            searchBar.searchBarStyle = .minimal
            searchBar.autocapitalizationType = .none
            return searchBar
        }
        
        func updateUIView(_ uiView: UISearchBar, context: Context) {
            uiView.text = text
        }
        
        func makeCoordinator() -> SearchBar.Coordinator {
            return Coordinator(text: $text)
        }
        
        class Coordinator: NSObject, UISearchBarDelegate {
            
            @Binding var text: String
            
            init(text: Binding<String>) {
                _text = text
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                text = searchText
            }
        }
    }
    
struct AddFriendView: View {
    @State private var email = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Image("TimerViewBG") // Replace this with your background image name
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Section(header: Text("Friend's Email")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                
                Section {
                    Button(action: {
                        // Search for friend with email and send friend request
                        authViewModel.sendFriendRequest(toEmail: email)
                    }) {
                        Text("Send Friend Request")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
            .padding()
           
        }
        .navigationTitle("Add Friend")
    }
}
    
    
    
struct FriendRequestsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Image("TimerViewBG") // Replace this with your background image name
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    ForEach(authViewModel.friendRequests) { friendRequest in
                        HStack {
                            Text(friendRequest.email) // Display the friend request ID here
                            Spacer()
                            Button(action: {
                                authViewModel.acceptFriendRequest(fromUserId: friendRequest.id)
                                print("Accept working?")
                            }) {
                                Text("Accept")
                            }
                            Button(action: {
                                authViewModel.declineFriendRequest(fromUserId: friendRequest.id)
                                print("Decline working?")
                            }) {
                                Text("Decline")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        Divider()  // Adding Divider to mimic List behavior
                    }
                    .padding()  // Add padding to mimic List behavior
                }
            }
        }
        .onAppear {
            authViewModel.fetchFriendRequests()
        }
        .navigationTitle("Friend Requests")
    }
}


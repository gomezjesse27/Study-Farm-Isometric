//
//  ShopView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//

import Foundation
import SwiftUI


struct ShopView: View {
    @ObservedObject var shopViewModel = ShopViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    @State var showAnimalSellView = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showAnimalSellView = true
                }) {
                    Image(systemName: "list.bullet")
                        .font(.title)
                        .padding()
                }

                Text("Shop")
                    .font(.largeTitle)
                    .bold()
            }

            Text("You have \(shopViewModel.currency) Farm Bucks.")
                .font(.headline)
                .padding(.horizontal)

            ScrollView {
                VStack {
                    ForEach(shopViewModel.crateOptions) { crate in
                        CrateView(crateImage: crate.image,
                                  crateName: crate.name,
                                  crateDescription: crate.description,
                                  cratePrice: crate.price) {
                            crate.buyAction()
                        }
                    }
                }
                .padding()
            }

            Text(shopViewModel.message)
                .padding(.horizontal)

            Text(shopViewModel.errorMessage)
                .foregroundColor(.red)
                .padding(.horizontal)
        }
        .background(Color(red: 188/255, green: 224/255, blue: 247/255).edgesIgnoringSafeArea(.all))
        .fullScreenCover(isPresented: $showAnimalSellView) {
            AnimalSellView(authViewModel: authViewModel)
        }

        }
    }



struct AnimalSellView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showPopup = false
    @State private var sellQuantity = ""
    @State private var activeAnimal: (name: String, count: Int)? = nil

    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                Spacer().frame(width: 50) // Add space before title
                Text("Sell Animals")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            ScrollView {
                ForEach(authViewModel.userAnimalCounts, id: \.name) { animal in
                    HStack {
                        Text("\(animal.name)")
                            .font(.title2)
                        Spacer()
                        Text("\(animal.count)")
                            .font(.title2)
                            .frame(height: 30) // Adjust to vertically center the count
                        Spacer().frame(width: 50)
                        Button(action: {
                            activeAnimal = animal
                            showPopup = true
                        }) {
                            Text("Sell")
                                .padding() // Padding for text within button
                                .frame(minWidth: 70) // Ensures button has a minimum width
                                .background(Color(red: 174/255, green: 234/255, blue: 198/255)) // Button's pastel green background color
                                .foregroundColor(.white) // Button's text color
                                .cornerRadius(10) // Rounded corners
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color(red: 168/255, green: 204/255, blue: 227/255)) // Darker blue background
                    .cornerRadius(10)
                }
            }
            if !authViewModel.sellAnimalError.isEmpty {
                Text(authViewModel.sellAnimalError)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            authViewModel.getUserAnimalCounts()
        }
        .background(Color(red: 188/255, green: 224/255, blue: 247/255))
        .overlay(Group {
            if showPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all, edges: .all)
                    .onTapGesture {
                        showPopup = false
                    }
                VStack {
                    Text("Sell \(activeAnimal?.name ?? "")")
                        .font(.headline)
                    Text("10 Farm Bucks per animal.")
                        .font(.subheadline)
                    Text("Enter amount of \(activeAnimal?.name ?? "animal") to sell") // Include animal name in prompt
                        .font(.subheadline)
                        .foregroundColor(.black)
                    TextField("", text: $sellQuantity)
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                    Button(action: {
                        if let animalName = activeAnimal?.name, let quantity = Int(sellQuantity) {
                            authViewModel.sellAnimal(animalName: animalName, quantity: quantity) { success in
                                if success {
                                    sellQuantity = ""
                                    activeAnimal = nil
                                    authViewModel.sellAnimalError = ""
                                    showPopup = false
                                    authViewModel.getUserAnimalCounts()
                                }
                            }
                        }
                    }) {
                        Text("Confirm Sell")
                    }
                    .padding()
                    .background(Color(red: 174/255, green: 234/255, blue: 198/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Button(action: {
                        showPopup = false
                    }) {
                        Text("Cancel")
                    }
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding()
            }
        })
    }
}










//
//  CrateView.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/23/23.
//

import Foundation
import SwiftUI
struct CrateView: View {
    var crateImage: String
    var crateName: String
    var crateDescription: String
    var cratePrice: Int
    var onBuy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Image(crateImage) // Assumes image is available in assets
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .shadow(radius: 10)
            Text(crateName)
                .font(.title)
                .bold()
            Text(crateDescription)
            Button(action: {
                onBuy()
            }) {
                HStack {
                    Spacer()
                    Text("Buy for \(cratePrice) Farm Bucks")
                    Spacer()
                }
                .padding() // Add padding to the text
                .background(Color(red: 174/255, green: 234/255, blue: 198/255)) // Button's pastel green background color
                .foregroundColor(.white) // Button's text color
                .cornerRadius(10) // Rounded corners
            }
            .padding(.bottom)
        }
    }
}



/*Still a lot of errors:
 ShopView:
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

     var body: some View {
         VStack {
             Text("Shop")
                 .font(.largeTitle)
                 .bold()
                 .padding()

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
                             shopViewModel.buyCrate(crate: crate)
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
         
     }
 }
 'buyCrate' is inaccessible due to 'private' protection level

 shopviewmodel:
 import Foundation
 import Combine

 struct Crate: Identifiable {
     let id = UUID()
     let image: String
     let name: String
     let description: String
     let price: Int
     let buyAction: () -> Void
 }

 class ShopViewModel: ObservableObject {
     @Published var message = ""
     @Published var errorMessage = ""
     @Published var currency = 0
     
     let authViewModel = AuthViewModel()

     let commonCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
     let uncommonCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
     let rareCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
     let superRareCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
     let exceedinglyRareCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]

     let crateOptions: [Crate]

     init() {
         self.crateOptions = [
             Crate(image: "commonCrate", name: "Common Crate", description: "Contains common animals", price: 10, buyAction: { [weak self] in self?.buyCommonCrate() }),
             Crate(image: "uncommonCrate", name: "Uncommon Crate", description: "Contains uncommon animals", price: 20, buyAction: { [weak self] in self?.buyUncommonCrate() }),
             Crate(image: "rareCrate", name: "Rare Crate", description: "Contains rare animals", price: 30, buyAction: { [weak self] in self?.buyRareCrate() }),
             Crate(image: "superRareCrate", name: "Super Rare Crate", description: "Contains super rare animals", price: 40, buyAction: { [weak self] in self?.buySuperRareCrate() }),
             Crate(image: "exceedinglyRareCrate", name: "Exceedingly Rare Crate", description: "Contains exceedingly rare animals", price: 50, buyAction: { [weak self] in self?.buyExceedinglyRareCrate() })
         ]


         authViewModel.getUserCurrency { (currency) in
             self.currency = currency
         }
     }
     
     private func buyCrate(cratePrice: Int, crateAnimals: [String]) {
         guard currency >= cratePrice else {
             errorMessage = "You don't have enough Farm Bucks to buy a crate."
             return
         }
         
         let randomAnimalIndex = Int.random(in: 0..<crateAnimals.count)
         let randomAnimalName = crateAnimals[randomAnimalIndex]
         
         currency -= cratePrice
         authViewModel.saveUserCurrency(currency)
         authViewModel.incrementUserAnimalCount(animalName: randomAnimalName)
         
         message = "Congratulations! You received a \(randomAnimalName) from the crate."
     }

     func buyCommonCrate() {
         buyCrate(cratePrice: 10, crateAnimals: commonCrateAnimals)
     }

     func buyUncommonCrate() {
         buyCrate(cratePrice: 20, crateAnimals: uncommonCrateAnimals)
     }

     func buyRareCrate() {
         buyCrate(cratePrice: 30, crateAnimals: rareCrateAnimals)
     }

     func buySuperRareCrate() {
         buyCrate(cratePrice: 40, crateAnimals: superRareCrateAnimals)
     }

     func buyExceedinglyRareCrate() {
         buyCrate(cratePrice: 50, crateAnimals: exceedinglyRareCrateAnimals)
     }
 }

 Variable 'self.crateOptions' used before being initialized
 Variable 'self.crateOptions' used before being initialized
 Variable 'self.crateOptions' used before being initialized
 Variable 'self.crateOptions' used before being initialized
 Variable 'self.crateOptions' used before being initialized

 Crateview:

 //
 //  CrateView.swift
 //  Study Farm
 //
 //  Created by Jaysen Gomez on 5/23/23.
 //

 import Foundation
 import SwiftUI
 struct CrateView: View {
     var crateImage: String
     var crateName: String
     var crateDescription: String
     var cratePrice: Int
     var onBuy: () -> Void

     var body: some View {
         VStack(alignment: .leading) {
             Image(crateImage) // Assumes image is available in assets
                 .resizable()
                 .scaledToFit()
                 .cornerRadius(10)
                 .shadow(radius: 10)
             Text(crateName)
                 .font(.title)
                 .bold()
             Text(crateDescription)
             Button(action: {
                 crate.buyAction()
             }) {
                 Text("Buy for \(cratePrice) Farm Bucks")
             }
             .buttonStyle(.bordered)
             .controlSize(.large)
             .padding(.top)
         }
         .padding(.bottom)
     }
 }

 Cannot find 'crate' in scope*/

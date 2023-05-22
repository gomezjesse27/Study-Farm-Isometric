//
//  ShopViewModel.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/22/23.
//



import Foundation
import Combine

class ShopViewModel: ObservableObject {
    @Published var message = ""
    @Published var errorMessage = ""
    @Published var currency = 0
    
    let authViewModel = AuthViewModel()
    let cratePrice = 10
    let animals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
    
    init() {
        authViewModel.getUserCurrency { (currency) in
            self.currency = currency
        }
    }
    
    func buyAnimalCrate() {
        guard currency >= cratePrice else {
            errorMessage = "You don't have enough Farm Bucks to buy a crate."
            return
        }
        
        let randomAnimalIndex = Int.random(in: 0..<animals.count)
        let randomAnimalName = animals[randomAnimalIndex]
        
        currency -= cratePrice
        authViewModel.saveUserCurrency(currency)
        authViewModel.incrementUserAnimalCount(animalName: randomAnimalName)
        
        message = "Congratulations! You received a \(randomAnimalName) from the crate."
    }
}

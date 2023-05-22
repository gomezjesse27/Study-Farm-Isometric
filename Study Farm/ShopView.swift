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
            Text("Welcome to the Shop!")
            Text("You have \(shopViewModel.currency) Farm Bucks.")
            Button(action: {
                shopViewModel.buyAnimalCrate()
            }) {
                Text("Buy Animal Crate for \(shopViewModel.cratePrice) Farm Bucks")
            }
            Text(shopViewModel.message)
            Text(shopViewModel.errorMessage)
        }
        .onAppear {
            shopViewModel.authViewModel.getUserCurrency { (currency) in
                self.shopViewModel.currency = currency
            }
        }
    }
}


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
        }.background(Color(red: 0.690, green: 0.878, blue: 0.902).edgesIgnoringSafeArea(.all))
        
    }
}

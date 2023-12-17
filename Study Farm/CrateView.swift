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
            
            Image(crateImage)
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



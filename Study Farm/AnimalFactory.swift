//
//  AnimalFactory.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//


import Foundation
struct AnimalFactory {
    static func getAnimal(name: String) -> Animal {
        switch name {
        case "Colobus":
           return Animal(name: "Colobus", model: "Colobus_Idle_A", texture: "T_Colobus", animations: ["Colobus_Clicked", "Colobus_Idle_A", "Colobus_Walk"])
        case "Colobus1":
           return Animal(name: "Colobus", model: "Colobus_Idle_A", texture: "T_Colobus", animations: ["Colobus_Clicked", "Colobus_Idle_A", "Colobus_Walk"])
       
        default:
            return Animal(name: "Colobus", model: "Colobus_Idle_A", texture: "T_Colobus", animations: ["Colobus_Clicked", "Colobus_Idle_A", "Colobus_Walk"])
        }
    }
}


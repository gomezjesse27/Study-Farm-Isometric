//
//  Animal.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/21/23.
//

import Foundation
import SceneKit

struct Animal {
    let name: String
    let model: String
    let texture: String
    let animations: [String]
    var node: SCNNode?
    var count: Int
    
    init(name: String, model: String, texture: String, animations: [String]) {
        self.name = name
        self.model = model
        self.texture = texture
        self.animations = animations
        self.count = 0
        loadModel()
    }
    mutating func setCount(_ count: Int) {
        self.count = count
    }
    mutating func loadModel() {
        // Load the 3D model
        guard let modelScene = SCNScene(named: "\(self.model).dae"),
              let modelNode = modelScene.rootNode.childNodes.first else {
            print("Failed to load \(self.name) model from \(self.model).dae")
            return
        }
        
        //modelNode.position = SCNVector3(0, 30, 0)

        // Add texture to the model
       
        
        // Adjust orientation of the model
        modelNode.eulerAngles.x = Float.pi / 2 // Adjust this value as needed
        
        self.node = modelNode
        
        // Load the animations
        for animationName in animations {
            if let animationScene = SCNScene(named: animationName),
               let animationNode = animationScene.rootNode.childNodes.first,
               let animationKey = animationNode.animationKeys.first {
                
                if let animationPlayer = animationNode.animationPlayer(forKey: animationKey) {
                    let animation = animationPlayer.animation
                    modelNode.addAnimationPlayer(animationPlayer, forKey: animationKey)
                } else {
                    print("Failed to load \(self.name) animation from \(animationName)")
                }
            }
        }
    }
    
    
}

//
//  StateMachine.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/22/23.
//

import Foundation
import QuartzCore

import SceneKit

class StateMachine {
    private var states: [String: SCNAnimation]
    private var currentNode: SCNNode
    
    init(node: SCNNode, states: [String: SCNAnimation]) {
        self.states = states
        self.currentNode = node
    }
    
    func transition(toState state: String) {
        guard let animation = states[state] else { return }
        
        currentNode.removeAllAnimations()
        currentNode.addAnimation(animation, forKey: state)
    }
}


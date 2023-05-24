//
//  MovementController.swift
//  Study Farm
//
//  Created by Jaysen Gomez on 5/22/23.
//

import Foundation
import SceneKit
import QuartzCore

class MovementController {
    private var node: SCNNode
    private var grid: Grid
    private var stateMachine: StateMachine
    private var idleAnimation: String
    private var walkAnimation: String
    private var timer: Timer?
    
    init(node: SCNNode, grid: Grid, stateMachine: StateMachine, idleAnimation: String, walkAnimation: String) {
        self.node = node
        self.grid = grid
        self.stateMachine = stateMachine
        self.idleAnimation = idleAnimation
        self.walkAnimation = walkAnimation
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.stateMachine.transition(toState: self.walkAnimation)
            self.moveRandomly()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.stateMachine.transition(toState: self.idleAnimation)
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func moveRandomly() {
        if let freeCell = grid.randomFreeCell() {
            grid.occupyCell(x: freeCell.x, y: freeCell.y)
            let moveAction = SCNAction.move(to: SCNVector3(freeCell.x, 0, freeCell.y), duration: 2)
            node.runAction(moveAction)
        }
    }
}

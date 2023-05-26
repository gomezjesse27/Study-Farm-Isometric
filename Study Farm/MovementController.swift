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
    private var canMove = true
    private var moveDelay: TimeInterval = 5.0
    
    init(node: SCNNode, grid: Grid, stateMachine: StateMachine, idleAnimation: String, walkAnimation: String) {
        self.node = node
        self.grid = grid
        self.stateMachine = stateMachine
        self.idleAnimation = idleAnimation
        self.walkAnimation = walkAnimation
    }
    
    func start() {
        let randomStartTime = Double.random(in: 0.0...10.0)  // Random start time between 0 and 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + randomStartTime) {
            self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                self.stateMachine.transition(toState: self.walkAnimation)
                self.moveRandomly()
                let randomIdleTime = Double.random(in: 2.0...5.0)  // Random idle time between 2 and 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + randomIdleTime) {
                    self.stateMachine.transition(toState: self.idleAnimation)
                }
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func moveRandomly() {
           if canMove, let freeCell = grid.randomFreeCell() {
               canMove = false
               grid.occupyCell(x: freeCell.x, y: freeCell.y)

               let currentCell = grid.worldToGrid(x: node.position.x, y: node.position.z)
               grid.freeCell(x: currentCell.x, y: currentCell.y)

               let worldCoordinates = grid.gridToWorld(x: freeCell.x, y: freeCell.y)

               let moveAction = SCNAction.move(to: SCNVector3(worldCoordinates.x, node.position.y, worldCoordinates.y), duration: 7.0)
               let dx = worldCoordinates.x - node.position.x
               let dz = worldCoordinates.y - node.position.z
               let angle = atan2(dz, dx)
               node.eulerAngles.y = -Float(angle) + Float.pi / 2
               
               node.runAction(moveAction) { [weak self] in
                   DispatchQueue.main.asyncAfter(deadline: .now() + (self?.moveDelay ?? 5.0)) {
                       self?.canMove = true
                   }
               }
           }
       }
   }



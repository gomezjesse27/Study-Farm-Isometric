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
        print("Start moving")
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                print("Transition to walk") // Debug print
                self.stateMachine.transition(toState: self.walkAnimation)
                self.moveRandomly()
                let randomIdleTime = Double.random(in: 6.0...10.0)  // Random idle time between 2 and 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + randomIdleTime) {
                    print("Transition to idle") // Debug print
                    self.stateMachine.transition(toState: self.idleAnimation)
                }
            }
        }
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func moveRandomly() {
        print("moverand being called?")
                if let freeCell = grid.randomFreeCell() {
                    print("Moving to cell \(freeCell.x), \(freeCell.y)")
                    grid.occupyCell(x: freeCell.x, y: freeCell.y)

                    let currentCell = grid.worldToGrid(x: node.position.x, y: node.position.z)
                    grid.freeCell(x: currentCell.x, y: currentCell.y)

                    let worldCoordinates = grid.gridToWorld(x: freeCell.x, y: freeCell.y) // convert the grid coordinates to world coordinates
                    let moveAction = SCNAction.move(to: SCNVector3(worldCoordinates.x, 0, worldCoordinates.y), duration: 2) // move the animal using world coordinates
                    node.runAction(moveAction)
                }
            }
        }


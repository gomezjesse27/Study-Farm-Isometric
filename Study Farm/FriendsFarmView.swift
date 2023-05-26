import Foundation
import SwiftUI
import SceneKit

struct FriendsFarmView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var scene: SCNScene = SCNScene()
    @State private var cameraNode = SCNNode()
    
    @State private var grid: Grid = Grid(size: 20)
    let gridSize: Int = 20
    
    var friendID: String // Friend's ID is passed to the view
    var friendEmail: String // Friend's email is passed to the view
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(friendEmail) // Display friend's email at the top right
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                    .padding(.trailing, 5)
            }
            
            SceneView(scene: scene,
                      pointOfView: cameraNode,
                      options: [],
                      preferredFramesPerSecond: 60,
                      antialiasingMode: .multisampling4X)
                .ignoresSafeArea()
                .frame(maxHeight: .infinity) // Force SceneView to take up all vertical space
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dragSpeed: CGFloat = 0.002  // Decrease this to slow down the panning speed
                            let newX = cameraNode.position.x - Float(value.translation.width) * Float(dragSpeed)
                            let newZ = cameraNode.position.z - Float(value.translation.height) * Float(dragSpeed)
                            cameraNode.position.x = min(max(newX, -Float(gridSize)/2), Float(gridSize)/2)
                            cameraNode.position.z = min(max(newZ, -Float(gridSize)/2 - 2), Float(gridSize)/2 + 2) // Adjust the -2 and +2 to limit the panning range
                        }

                )
                .gesture(
                    MagnificationGesture()
                            .onChanged { value in
                                let zoom = cameraNode.camera?.orthographicScale ?? 1
                                let newZoom = zoom / Double(value)
                                let clampedZoom = min(max(newZoom, 10), 30)
                                cameraNode.camera?.orthographicScale = clampedZoom
                            }
                )
                .onAppear {
                    setupScene(friendID: friendID)
                }
        }
    }

    func setupScene(friendID: String) {
            setupEnvironment()
            setupGrid()
            addAnimals(for: friendID)
        }
    
    
    func setupEnvironment() {
        scene.background.contents = UIColor.systemTeal
        setupCamera()
        setupLighting()
    }
    
    func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 3) // Adjust this to move the initial camera position
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 14 // Adjust this to zoom out at the start
        cameraNode.camera?.zFar = 1000
        cameraNode.eulerAngles = SCNVector3(-45.degreesToRadians, 45.degreesToRadians, 0)
        scene.rootNode.addChildNode(cameraNode)
    }

    
    func setupLighting() {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light!.type = .directional
        directionalLightNode.light!.color = UIColor(white: 1.0, alpha: 1.0)
        directionalLightNode.eulerAngles = SCNVector3(-45.degreesToRadians, -45.degreesToRadians, 0)
        scene.rootNode.addChildNode(directionalLightNode)
    }
    
    func setupGrid() {
        for i in stride(from: -gridSize/2, to: gridSize/2, by: 1) {
            for j in stride(from: -gridSize/2, to: gridSize/2, by: 1) {
                let node = SCNNode(geometry: SCNBox(width: 1, height: 0.1, length: 1, chamferRadius: 0))
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                node.position = SCNVector3(Float(i) + 0.5, 0, Float(j) + 0.5)
                scene.rootNode.addChildNode(node)
            }
        }
    }
    func addAnimals(for friendID: String) {
         scene.rootNode.enumerateChildNodes { node, stop in
             if node.name == "animal" {
                 node.removeFromParentNode()
             }
         }
        authViewModel.getFriendAnimals(for: friendID, grid: grid)
               for animal in authViewModel.friendAnimals {
                if let animalNode = animal.node {
                    animalNode.name = "animal"
                    if let freeCell = grid.randomFreeCell() {
                        grid.occupyCell(x: freeCell.x, y: freeCell.y)
                        let worldCoordinates = grid.gridToWorld(x: freeCell.x, y: freeCell.y)

                        // calculate the height of the model
                        let (min, max) = animalNode.boundingBox
                        let height = max.y - min.y

                        // adjust the y position of the model
                        animalNode.position = SCNVector3(worldCoordinates.x, height / 2, worldCoordinates.y)
                        scene.rootNode.addChildNode(animalNode)

                        // Start moving the animal
                        
                        animal.setupStateMachine() // make sure to setup state machine for the animal
                        animal.setupMovementController(grid: grid) // make sure the grid is set before starting movement
                        animal.startMoving()
                    } else {
                        // Handle the case where there are no free cells
                        print("No free cells remaining")
                    }
                }
            }
        }
}



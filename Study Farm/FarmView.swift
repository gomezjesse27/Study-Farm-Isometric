import Foundation
import SwiftUI
import SceneKit

struct FarmView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var scene: SCNScene = SCNScene()
    @State private var cameraNode = SCNNode()
    
    let gridSize: Float = 20// To make it configurable
    
    var body: some View {
            VStack {
                SceneView(scene: scene, pointOfView: cameraNode, options: [], preferredFramesPerSecond: 60, antialiasingMode: .multisampling4X)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let dragSpeed: CGFloat = 0.004
                                let newX = cameraNode.position.x - Float(value.translation.width) * Float(dragSpeed)
                                let newZ = cameraNode.position.z - Float(value.translation.height) * Float(dragSpeed)
                                cameraNode.position.x = min(max(newX, -gridSize/2), gridSize/2)
                                cameraNode.position.z = min(max(newZ, -gridSize/2), gridSize/2)
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let zoom = cameraNode.camera?.orthographicScale ?? 1
                                let newZoom = zoom / Double(value)
                                let clampedZoom = min(max(newZoom, 1), 30)
                                cameraNode.camera?.orthographicScale = clampedZoom
                                cameraNode.position.y = Float(clampedZoom) * 0.7
                            }
                    )
                    .onAppear(perform: setupScene)
            }
        }
    
    func setupScene() {
        setupEnvironment()
        setupGrid()
        addAnimals()
    }
    
    func setupEnvironment() {
        scene.background.contents = UIColor.lightGray
        setupCamera()
        setupLighting()
    }
    
    func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 7, z: 0)
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 10
        cameraNode.camera?.zFar = 500
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
                node.position = SCNVector3(i + 0.5, 0, j + 0.5)
                scene.rootNode.addChildNode(node)
            }
        }
    }
    
    func addAnimals() {
        authViewModel.getUserAnimals()
        for animal in authViewModel.userAnimals {
            for _ in 0..<animal.count {
                if let model = animal.node?.clone() { // Clone the model node for each animal instance
                            print("Cloned model: \(model)")
                            let x = Float.random(in: (-gridSize / 2.0)...(gridSize / 2.0))
                            let z = Float.random(in: (-gridSize / 2.0)...(gridSize / 2.0))
                            model.position = SCNVector3(x, 10000, z)
                            print("Model position after setting: \(model.position)")
                    for child in model.childNodes {
                                       print("Child node position: \(child.position)")
                                   }
                            scene.rootNode.addChildNode(model)
                        } else {
                            print("Failed to clone model")
                        }
            }
        }
    }
    
    
}

extension Int {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}


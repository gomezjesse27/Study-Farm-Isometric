import SceneKit
import QuartzCore

class Animal:Equatable {
    let name: String
    let model: String
    let texture: String
    let animations: [String]
    var node: SCNNode?
    var count: Int
    var stateMachine: StateMachine?
    var movementController: MovementController?
    var idleAnimation: String?
    var walkAnimation: String?
    
    init(name: String, model: String, texture: String, animations: [String]) {
        self.name = name
        self.model = model
        self.texture = texture
        self.animations = animations
        self.count = 0
        loadModel()
    }
    
    func loadModel() {
        if let virtualObjectScene = SCNScene(named: "\(self.model).scn") {
            self.node = virtualObjectScene.rootNode
            self.node?.enumerateChildNodes { (childNode, stop) in
                childNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: texture)
            }
        }
    }
    static func == (lhs: Animal, rhs: Animal) -> Bool {
           return lhs.name == rhs.name && lhs.model == rhs.model && lhs.texture == rhs.texture
           // and so on for each property you consider makes an animal unique...
       }
        
    func setupStateMachine() {
        print("setupstatemachine")
        var animationStates: [String: SCNAnimation] = [:]

        for animationName in animations {
            if let animationScene = SCNScene(named: animationName),
               let animationNode = animationScene.rootNode.childNodes.first,
               let animationKey = animationNode.animationKeys.first {
                print("Loading animation: \(animationKey)") // Print debug info
                if let animationPlayer = animationNode.animationPlayer(forKey: animationKey),
                   let animation = animationPlayer.animation as? SCNAnimation {
                    animationStates[animationKey] = animation
                } else {
                    print("Failed to load \(self.name) animation from \(animationName)")
                }
            }
        }
        
        // Directly assign the idle and walk animations
        self.idleAnimation = "\(self.name)_Idle_A"
        self.walkAnimation = "\(self.name)_Walk"
        
        if let node = self.node {
            self.stateMachine = StateMachine(node: node, states: animationStates)
        }
    }
    func startMoving() {
        print("startmoving()")
            movementController?.start()
        }
        
        func setupMovementController(grid: Grid) {
            print("setupmovecontrol")
            if let node = self.node, let stateMachine = self.stateMachine,
               let idleAnimation = self.idleAnimation, let walkAnimation = self.walkAnimation {
                self.movementController = MovementController(node: node, grid: grid, stateMachine: stateMachine, idleAnimation: idleAnimation, walkAnimation: walkAnimation)
            }
        }
        
    }
    


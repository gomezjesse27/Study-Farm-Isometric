import Foundation

enum AnimalFactoryError: Error {
    case unknownAnimalType(String)
}

struct AnimalFactory {
    static func getAnimal(name: String, grid: Grid) throws -> Animal {
        let animal: Animal
        switch name {
        case "Colobus":
            animal = Animal(name: "Colobus", model: "Colobus_Idle_A", texture: "T_Colobus", animations: ["Colobus_Clicked", "Colobus_Idle_A", "Colobus_Walk"])
        case "Sheep":
            animal = Animal(name: "Sheep", model: "Sheep_Idle_A", texture: "T_Sheep", animations: ["Sheep_Clicked", "Sheep_Idle_A", "Sheep_Walk"])
        default:
            // handle error: the string didn't match any known type
            throw AnimalFactoryError.unknownAnimalType(name)
        }
        
        animal.setupStateMachine()
        animal.setupMovementController(grid: grid)
        animal.startMoving()
        return animal
    }
}


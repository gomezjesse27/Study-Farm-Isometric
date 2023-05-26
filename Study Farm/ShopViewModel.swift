import Foundation
import Combine

struct Crate: Identifiable {
    let id = UUID()
    let image: String
    let name: String
    let description: String
    let price: Int
    let buyAction: () -> Void
}

class ShopViewModel: ObservableObject {
    @Published var message = ""
    @Published var errorMessage = ""
    @Published var currency = 0
    
    let authViewModel = AuthViewModel()
    
    let commonCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
    let uncommonCrateAnimals: [String] = ["Sheep", "Sheep", "Sheep", "Sheep", "Sheep"]
    let rareCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
    let superRareCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
    let exceedinglyRareCrateAnimals: [String] = ["Colobus", "Colobus", "Colobus", "Colobus", "Colobus"]
    
    var crateOptions: [Crate] = []
    
    init() {
        createCrateOptions()
        authViewModel.getUserCurrency { (currency) in
            self.currency = currency
        }
    }
    
    private func buyCrate(cratePrice: Int, crateAnimals: [String]) {
        guard currency >= cratePrice else {
            errorMessage = "You don't have enough Farm Bucks to buy a crate."
            return
        }
        
        let randomAnimalIndex = Int.random(in: 0..<crateAnimals.count)
        let randomAnimalName = crateAnimals[randomAnimalIndex]
        
        currency -= cratePrice
        authViewModel.saveUserCurrency(currency)
        authViewModel.incrementUserAnimalCount(animalName: randomAnimalName)
        
        message = "Congratulations! You received a \(randomAnimalName) from the crate."
    }
    
    func createCrateOptions() {
        self.crateOptions = [
            Crate(image: "crate", name: "Common Crate", description: "Contains common animals", price: 10, buyAction: { [weak self] in self?.buyCommonCrate() }),
            Crate(image: "crate", name: "Uncommon Crate", description: "Contains uncommon animals", price: 20, buyAction: { [weak self] in self?.buyUncommonCrate() }),
            Crate(image: "crate", name: "Rare Crate", description: "Contains rare animals", price: 30, buyAction: { [weak self] in self?.buyRareCrate() }),
            Crate(image: "crate", name: "Super Rare Crate", description: "Contains super rare animals", price: 40, buyAction: { [weak self] in self?.buySuperRareCrate() }),
            Crate(image: "crate", name: "Exceedingly Rare Crate", description: "Contains exceedingly rare animals", price: 50, buyAction: { [weak self] in self?.buyExceedinglyRareCrate() })
        ]
    }
    
    func buyCommonCrate() {
        buyCrate(cratePrice: 10, crateAnimals: commonCrateAnimals)
    }
    
    func buyUncommonCrate() {
        buyCrate(cratePrice: 20, crateAnimals: uncommonCrateAnimals)
    }
    
    func buyRareCrate() {
        buyCrate(cratePrice: 30, crateAnimals: rareCrateAnimals)
    }
    
    func buySuperRareCrate() {
        buyCrate(cratePrice: 40, crateAnimals: superRareCrateAnimals)
    }
    
    func buyExceedinglyRareCrate() {
        buyCrate(cratePrice: 50, crateAnimals: exceedinglyRareCrateAnimals)
    }
}


import Foundation

struct Allergens {
    let allergens: [String]
    let name: String
}

extension Allergens {
    init(from allergensResult: AllergensResult) {
        self.allergens = allergensResult.allergens
//        self.name = [allergensResult.brand, allergensResult.name].compactMap { $0 }.joined(separator: " ")
        self.name = allergensResult.name
    }
}

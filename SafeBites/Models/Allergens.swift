import Foundation

struct Allergens {
    let allergens: [String]
    let name: String?
}

extension Allergens {
    init(from allergensResponseBody: AllergensResponseBody) {
        self.allergens = allergensResponseBody.allergens
        self.name = allergensResponseBody.name
    }
}

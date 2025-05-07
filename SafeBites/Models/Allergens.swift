import Foundation

struct Allergens {
    let allergensTags: [String]
    let name: String?
    let allergensNames: [String]
}

extension Allergens {
    init(from allergensResponseBody: AllergensResponseBody) {
        self.allergensTags = allergensResponseBody.allergens
        self.name = allergensResponseBody.name
        self.allergensNames = AllergenName.getAllergensName(self.allergensTags)
    }
}

enum AllergenName: String {
    case milk = "Молоко"
    case soybeans = "Соя"
    
    static func getAllergensName(_ tags: [String]) -> [String] {
        var allergensNames: [String] = []
        for tag in tags {
            switch tag {
            case "en:milk":
                allergensNames.append(AllergenName.milk.rawValue)
            case "en:soybeans":
                allergensNames.append(AllergenName.soybeans.rawValue)
            default:
                allergensNames.append(tag)
            }
        }
        return allergensNames
    }
}

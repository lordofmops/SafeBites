import Foundation

struct ProductAllergens: Codable {
    let allergens: [String]
    
    private enum CodingKeys: String, CodingKey {
        case allergens = "allergens_tags"
    }
}

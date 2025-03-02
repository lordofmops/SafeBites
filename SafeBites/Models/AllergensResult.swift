import Foundation

struct AllergensResult: Codable {
    let allergens: [String]
    let name: String
    let brand: String
    
    private enum CodingKeys: String, CodingKey {
        case allergens = "allergens_tags"
        case name = "product_name"
        case brand = "brands"
    }
}

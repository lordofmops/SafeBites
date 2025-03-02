import Foundation

struct AllergensResult: Decodable {
    let allergens: [String]?
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case product
    }
    
    private enum ProductCodingKeys: String, CodingKey {
        case allergens = "allergens_tags"
        case name = "product_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let productContainer = try container.nestedContainer(keyedBy: ProductCodingKeys.self, forKey: .product)
        
        self.allergens = try productContainer.decodeIfPresent([String].self, forKey: .allergens) ?? []
        
        self.name = try productContainer.decode(String.self, forKey: .name)
    }
}

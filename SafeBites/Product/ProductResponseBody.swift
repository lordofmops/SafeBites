import Foundation

struct ProductResponseBody: Decodable {
    let code: String
    let allergens: [String]?
    let defaultName: String?
    let russianName: String?
    let quantity: String?
    let brand: String?
    let imageUrl: String?
    let ingredientsText: String?
    let ingredientsAnalysis: [String]?
    let stores: String?
    
    let energy: Double?
    let fat: Double?
    let saturatedFat: Double?
    let carbohydrates: Double?
    let sugars: Double?
    let fiber: Double?
    let proteins: Double?
    let salt: Double?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case product
    }
    
    private enum ProductCodingKeys: String, CodingKey {
        case allergens = "allergens_hierarchy"
        case defaultName = "product_name"
        case russianName = "product_name_ru"
        case quantity
        case brand = "brands"
        case imageUrl = "image_url"
        case ingredientsText = "ingredients_text"
        case ingredientsAnalysis = "ingredients_analysis_tags"
        case stores
        
        case nutriments
    }
    
    private enum NutrimentsCodingKeys: String, CodingKey {
        case energy = "energy_100g"
        case fat = "fat_100g"
        case saturatedFat = "saturated-fat_100g"
        case carbohydrates = "carbohydrates_100g"
        case sugars = "sugars_100g"
        case fiber = "fiber_100g"
        case proteins = "proteins_100g"
        case salt = "salt_100g"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let productContainer = try container.nestedContainer(keyedBy: ProductCodingKeys.self, forKey: .product)
        let nutrimentsContainer = try productContainer.nestedContainer(keyedBy: NutrimentsCodingKeys.self, forKey: .nutriments)
        
        self.code = try container.decode(String.self, forKey: .code)
        
        self.allergens = try productContainer.decodeIfPresent([String].self, forKey: .allergens)
        self.defaultName = try productContainer.decodeIfPresent(String.self, forKey: .defaultName)
        self.russianName = try productContainer.decodeIfPresent(String.self, forKey: .russianName)
        self.quantity = try productContainer.decodeIfPresent(String.self, forKey: .quantity)
        self.brand = try productContainer.decodeIfPresent(String.self, forKey: .brand)
        self.imageUrl = try productContainer.decodeIfPresent(String.self, forKey: .imageUrl)
        self.ingredientsText = try productContainer.decodeIfPresent(String.self, forKey: .ingredientsText)
        self.ingredientsAnalysis = try productContainer.decodeIfPresent([String].self, forKey: .ingredientsAnalysis)
        self.stores = try productContainer.decodeIfPresent(String.self, forKey: .stores)
        
        self.energy = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .energy)
        self.fat = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .fat)
        self.saturatedFat = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .saturatedFat)
        self.carbohydrates = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .carbohydrates)
        self.sugars = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .sugars)
        self.fiber = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .fiber)
        self.proteins = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .proteins)
        self.salt = try nutrimentsContainer.decodeIfPresent(Double.self, forKey: .salt)
    }
}

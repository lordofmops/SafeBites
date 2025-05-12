struct ProductSearchResponseBody: Decodable {
    let code: String
    let defaultName: String?
    let russianName: String?
    let brand: String?
    let imageUrl: String?
    let allergens: [String]?
    let ingredientsText: String?
    let ingredientsAnalysis: [String]?
    
    enum CodingKeys: String, CodingKey {
        case code
        case defaultName = "product_name"
        case russianName = "product_name_ru"
        case brand = "brands"
        case imageUrl = "image_front_url"
        case allergens = "allergens_tags"
        case ingredientsText = "ingredients_text"
        case ingredientsAnalysis = "ingredients_analysis_tags"
    }
}

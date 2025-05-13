import Foundation

struct Product {
    let barcode: String
    let allergensTags: [String]?
    let allergens: [String]?
    let name: String?
    let quantity: String?
    let nutrients: Nutriments
    let brand: String?
    let imageUrl: String?
    let ingredientsText: String?
    let veganSuitability: Suitability
    let vegetarianSuitability: Suitability
    let stores: String?
    
    var doesMatchRestrictions: Bool?
    var unmatchedTags: [String]?
}

extension Product {
    init(from productResponseBody: ProductResponseBody, doesMatchRestrictions: Bool? = nil, unmatchedTags: [String]? = nil) {
        self.barcode = productResponseBody.code
        self.allergensTags = productResponseBody.allergens
        self.allergens = productResponseBody.allergens != nil
            ? AllergenName.getAllergensName(productResponseBody.allergens!)
            : nil
        self.name = productResponseBody.russianName != nil
            ? productResponseBody.russianName
            : productResponseBody.defaultName
        self.quantity = productResponseBody.quantity
        self.nutrients = Nutriments(
            energy: productResponseBody.energy,
            fat: productResponseBody.fat,
            saturatedFat: productResponseBody.saturatedFat,
            carbohydrates: productResponseBody.carbohydrates,
            sugars: productResponseBody.sugars,
            fiber: productResponseBody.fiber,
            proteins: productResponseBody.proteins,
            salt: productResponseBody.salt)
        self.brand = productResponseBody.brand != nil
            ? productResponseBody.brand
            : nil
        self.imageUrl = productResponseBody.imageUrl
        self.ingredientsText = productResponseBody.ingredientsText
        self.stores = productResponseBody.stores
        
        self.doesMatchRestrictions = doesMatchRestrictions
        self.unmatchedTags = unmatchedTags
        
        self.veganSuitability = {
            let analysis = productResponseBody.ingredientsAnalysis ?? []
            if analysis.contains("en:non-vegan") {
                return .notSuitable
            } else if analysis.contains("en:vegan"){
                return .suitable
            } else {
                return .unknown
            }
        }()
        
        self.vegetarianSuitability = {
            let analysis = productResponseBody.ingredientsAnalysis ?? []
            
            if analysis.contains("en:non-vegetarian") {
                return .notSuitable
            } else if analysis.contains("en:vegetarian"){
                return .suitable
            } else {
                return .unknown
            }
        }()
    }
    
    mutating func addRestrictionSuitability(doesMatchRestrictions: Bool, unmatchedTags: [String]?) {
        self.doesMatchRestrictions = doesMatchRestrictions
        self.unmatchedTags = unmatchedTags
    }
}

extension Product {
    init(fromSearch response: ProductSearchResponseBody) {
        self.barcode = response.code
        self.allergensTags = response.allergens
        self.allergens = nil
        self.name = response.russianName != nil
            ? response.russianName
            : response.defaultName
        self.quantity = nil
        self.brand = response.brand
        self.imageUrl = response.imageUrl
        self.ingredientsText = response.ingredientsText
        self.veganSuitability = Suitability.fromAnalysis(response.ingredientsAnalysis, id: "en:vegan")
        self.vegetarianSuitability = Suitability.fromAnalysis(response.ingredientsAnalysis, id: "en:vegetarian")
        self.stores = nil

        self.nutrients = Nutriments(
            energy: nil, fat: nil, saturatedFat: nil,
            carbohydrates: nil, sugars: nil, fiber: nil,
            proteins: nil, salt: nil
        )

        self.doesMatchRestrictions = nil
        self.unmatchedTags = nil
    }
}

struct Nutriments {
    let energy: Double?
    let fat: Double?
    let saturatedFat: Double?
    let carbohydrates: Double?
    let sugars: Double?
    let fiber: Double?
    let proteins: Double?
    let salt: Double?
}

enum Suitability {
    case suitable
    case notSuitable
    case unknown

    static func fromAnalysis(_ tags: [String]?, id: String) -> Suitability {
        guard let tags else { return .unknown }
        if tags.contains("en:\(id)") { return .suitable }
        if tags.contains("en:non-\(id)") { return .notSuitable }
        return .unknown
    }
}

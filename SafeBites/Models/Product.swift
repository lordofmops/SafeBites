import Foundation

struct Product {
    let barcode: String
    let allergens: [String]?
    let name: String?
    let quantity: String?
    let nutrients: Nutriments
    let brand: String?
    let imageUrl: String?
    let ingredientsText: String?
    let stores: String?
    
    var isFavorite: Bool?
    var doesMatchRestrictions: Bool?
    var unmatchedTags: [String]?
}

extension Product {
    init(from productResponseBody: ProductResponseBody, isFavorite: Bool? = nil, doesMatchRestrictions: Bool? = nil, unmatchedTags: [String]? = nil) {
        self.barcode = productResponseBody.code
        self.allergens = productResponseBody.allergens
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
        
        self.isFavorite = isFavorite
        self.doesMatchRestrictions = doesMatchRestrictions
        self.unmatchedTags = unmatchedTags
    }
    
    mutating func addRestrictionSuitability(doesMatchRestrictions: Bool, unmatchedTags: [String]?) {
        self.doesMatchRestrictions = doesMatchRestrictions
        self.unmatchedTags = unmatchedTags
    }
    
    mutating func changeFavoriteStatus(isFavorite: Bool) {
        self.isFavorite = isFavorite
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

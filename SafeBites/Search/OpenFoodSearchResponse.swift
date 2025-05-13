struct OpenFoodSearchResponse: Decodable {
    let count: Int
    let products: [ProductSearchResponseBody]
}

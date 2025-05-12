struct OpenFoodSearchResponse: Decodable {
    let page_count: Int
    let products: [ProductSearchResponseBody]
}

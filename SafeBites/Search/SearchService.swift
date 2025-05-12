import Foundation

protocol SearchServiceProtocol {
    func searchProducts(query: String?, filters: SearchFilters?, page: Int, completion: @escaping (Result<[Product], Error>) -> Void)
    var totalPages: Int { get }
}

final class SearchService: SearchServiceProtocol {
    static let shared = SearchService()
    var totalPages: Int = 10

    private init() {}

    func searchProducts(query: String?, filters: SearchFilters?, page: Int, completion: @escaping (Result<[Product], Error>) -> Void) {
        print("[INFO] Searching products - query: \(query ?? "nil"), page: \(page)")
        var components = URLComponents(string: "https://ru.openfoodfacts.org/cgi/search.pl")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "fields", value: "code,product_name,product_name_ru,brands,image_front_url,ingredients_text,allergens_tags,ingredients_analysis_tags,quantity,categories_tags"),
            URLQueryItem(name: "page_size", value: "20"),
            URLQueryItem(name: "page", value: page.description)
        ]

        if let query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "search_terms", value: query))
        }

        if let filters {
            if filters.onlyVegan {
                queryItems.append(URLQueryItem(name: "tagtype_0", value: "ingredients_analysis"))
                queryItems.append(URLQueryItem(name: "tag_contains_0", value: "contains"))
                queryItems.append(URLQueryItem(name: "tag_0", value: "en:vegan"))
            }
            
            if filters.onlyVegetarian {
                queryItems.append(URLQueryItem(name: "tagtype_1", value: "ingredients_analysis"))
                queryItems.append(URLQueryItem(name: "tag_contains_1", value: "contains"))
                queryItems.append(URLQueryItem(name: "tag_1", value: "en:vegetarian"))
            }
            
            if !filters.excludedAllergens.isEmpty {
                for (index, allergen) in filters.excludedAllergens.enumerated() {
                    queryItems.append(URLQueryItem(name: "tagtype_\(index + 2)", value: "allergens"))
                    queryItems.append(URLQueryItem(name: "tag_contains_\(index + 2)", value: "does_not_contain"))
                    queryItems.append(URLQueryItem(name: "tag_\(index + 2)", value: "en:\(allergen)"))
                }
            }
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            print("[ERROR] [SearchService/searchProducts] Failed to create URL")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        print("[INFO] Search url: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.setValue("SafeBites/1.0", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("[ERROR] [SearchService/searchProducts] Network error: \(error)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[ERROR] [SearchService/searchProducts] Invalid response")
                completion(.failure(NetworkError.message("Invalid response")))
                return
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                print("[ERROR] [SearchService/searchProducts] Invalid status code: \(httpResponse.statusCode)")
                completion(.failure(NetworkError.message("Invalid status code")))
                return
            }

            guard let data else {
                print("[ERROR] [SearchService/searchProducts] No data received")
                completion(.failure(NetworkError.message("No data received")))
                return
            }

            do {
                let result = try JSONDecoder().decode(OpenFoodSearchResponse.self, from: data)
                print("[INFO] Decoded \(result.products.count) products, total page count \(result.page_count)")
                self.totalPages = result.page_count
                let products = result.products.map{ Product(fromSearch: $0) }
                completion(.success(products))
            } catch {
                print("[ERROR] [SearchService/searchProducts] Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

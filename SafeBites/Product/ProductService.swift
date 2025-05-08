import Foundation

protocol ProductServiceProtocol {
    var product: Product? { get }
    func getProductInfo(with barcode: String, completion: @escaping (Result<Product, Error>) -> Void)
}

final class ProductService: ProductServiceProtocol {
    static let shared = ProductService()
    
    private(set) var product: Product?
    private(set) var isFavorite: Bool?
    private(set) var doesMatchRestrictions: Bool?
    private(set) var unmatchedTags: [String]?
    
    // TODO: для нормальной архитектуры можно убрать отсюда продукт и собирать его по инициализатору в презентере
    private let restrictionsService = RestrictionsService.shared
    private let authTokenStorage = AuthTokenStorage.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func getProductInfo(with barcode: String, completion: @escaping (Result<Product, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != barcode else {
            print("[ERROR] [ProductService/getProductInfo] Product request already in progress with the same barcode")
            completion(.failure(NetworkError.message("Product request already in progress with the same barcode")))
            return
        }
        
        task?.cancel()
        lastCode = barcode
        
        guard let url = URL(string: Constants.defaultBaseURL + "product/\(barcode).json") else {
            print( "[ERROR] [ProductService/getProductInfo] Failed to create productURL")
            completion(.failure(NetworkError.message("Failed to create productURL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("SafeBites/1.0 (dadrobysheva@edu.hse.ru)", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProductResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    let product = Product(from: response)
                    self.product = product
                    if let token = self.authTokenStorage.token {
                        self.checkProductSuitability(for: token, product: product) { updatedProduct in
                            self.product = updatedProduct
                            print("[INFO] Product with barcode \(barcode): \(product.name ?? "no name") successfully fetched with updated suitability")
                            completion(.success(updatedProduct))
                        }
                    } else {
                        print("[INFO] Product with barcode \(barcode): \(product.name ?? "no name") successfully fetched")
                        completion(.success(product))
                    }
                case .failure(let error):
                    print("[ERROR] [ProductService/getProductInfo] Network request failed: \(error)")
                    completion(.failure(error))
                }
                
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func checkProductSuitability(for token: String, product: Product, completion: @escaping (Product) -> Void) {
        restrictionsService.getUserRestrictions(for: token) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                var updatedProduct = product
                
                switch result {
                case .success(let userRestrictions):
                    var conflictRestrictions: [Restriction] = []
                    
                    if let allergensTags = product.allergensTags {
                        conflictRestrictions.append(contentsOf: userRestrictions.filter { allergensTags.contains($0.tag) })
                    }
                    
                    let veganRestriction = userRestrictions.filter { $0.tag == "vegan" || $0.tag == "vegetarian" }
                    conflictRestrictions.append(contentsOf: veganRestriction)
                    
                    updatedProduct.addRestrictionSuitability(
                        doesMatchRestrictions: conflictRestrictions.isEmpty,
                        unmatchedTags: conflictRestrictions.map { $0.name }
                    )
                    
                case .failure(_):
                    print("[ERROR] [ProductService/checkProductSuitability] Failed to check product suitability")
                }
                completion(updatedProduct)
            }
        }
    }
}

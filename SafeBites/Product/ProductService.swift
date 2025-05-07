import Foundation

protocol ProductServiceProtocol {
    var product: Product? { get }
    func getProductInfo(with barcode: String, completion: @escaping (Result<Product, Error>) -> Void)
}

final class ProductService: ProductServiceProtocol {
    static let shared = ProductService()
    
    private(set) var product: Product?
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
                    completion(.success(product))
                    print("[INFO] Product with barcode \(barcode): \(product.name ?? "no name") successfully fetched")
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
}

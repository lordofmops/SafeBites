import Foundation

protocol ProductLoading {
    func fetchAllergens(for barcode: String, completion: @escaping (Result<Allergens, Error>) -> Void)
}

final class ProductLoader: ProductLoading {
    static let shared = ProductLoader()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchAllergens(for barcode: String, completion: @escaping (Result<Allergens, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != barcode else {
            print("Allergens request already in progress with the same barcode")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = barcode
        
        guard
            let request = makeAllergensRequest(barcode: barcode)
        else {
            print("Failed to make allergens request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<AllergensResult, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    let allergens = Allergens(from: response)
                    completion(.success(allergens))
                    print("Product for barcode \(barcode): \(allergens.name), allergens: \(allergens.allergens)")
                case .failure(let error):
                    print("Network request failed: \(error)")
                    completion(.failure(error))
                }
                
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: URL
    func makeAllergensRequest(barcode: String) -> URLRequest? {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else {
            print( "Failed to create allergensURL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
     }
}

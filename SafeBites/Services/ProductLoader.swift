import Foundation

protocol ProductLoading {
    func loadAllergens(for barcode: String, handler: @escaping (Result<ProductAllergens, Error>) -> Void)
}

struct ProductLoader: ProductLoading {
    // MARK: Network client
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: URL
    private var allergensURL: URL {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product") else {
            preconditionFailure("Unable to construct allergensURL")
        }
        return url
    }
    
    func loadAllergens(for barcode: String, handler: @escaping (Result<ProductAllergens, any Error>) -> Void) {
        let url = allergensURL.appendingPathComponent(barcode).appendingPathExtension("json")
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let productAllergens = try JSONDecoder().decode(ProductAllergens.self, from: data)
                    handler(.success(productAllergens))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

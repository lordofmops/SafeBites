import Foundation

protocol FavoritesServiceProtocol {
    func addToFavorites(_ barcode: String, token: String, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteFromFavorites(_ barcode: String, token: String, completion: @escaping (Result<Void, Error>) -> Void)
    func getFavorites(token: String, completion: @escaping (Result<[String], Error>) -> Void)
}

final class FavoritesService: FavoritesServiceProtocol {
    static let shared = FavoritesService()
    
    private init() {}
    
    func addToFavorites(_ barcode: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.favoritesRoute) else {
            print("[ERROR] [FavoritesService/addToFavorites] Failed to create favorites URL")
            completion(.failure(NetworkError.message("Failed to create favorites URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(["barcode": barcode])
        } catch(let error) {
            print("[ERROR] [FavoritesService/addToFavorites] Failed to serialize request body with error: \(error)")
            completion(.failure(NetworkError.message("Failed to serialize registration request body with error: \(error)")))
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<String, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    print("[INFO] Product \(barcode) added to favorites successfully")
                    completion(.success(()))
                case .failure(let error):
                    print("[ERROR] [FavoritesService/addToFavorites] Failed to add product to favorites with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to add product to favorites with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
    
    func deleteFromFavorites(_ barcode: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.favoritesRoute) else {
            print("[ERROR] [FavoritesService/deleteFromFavorites] Failed to create favorites URL")
            completion(.failure(NetworkError.message("Failed to create favorites URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(["barcode": barcode])
        } catch(let error) {
            print("[ERROR] [FavoritesService/deleteFromFavorites] Failed to serialize request body with error: \(error)")
            completion(.failure(NetworkError.message("Failed to serialize registration request body with error: \(error)")))
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<String, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    print("[INFO] Product \(barcode) deleted from favorites successfully")
                    completion(.success(()))
                case .failure(let error):
                    print("[ERROR] [FavoritesService/deleteFromFavorites] Failed to delete product from favorites with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to delete product from favorites with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
    
    func getFavorites(token: String, completion: @escaping (Result<[String], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.favoritesRoute) else {
            print("[ERROR] [FavoritesService/getFavorites] Failed to create favorites URL")
            completion(.failure(NetworkError.message("Failed to create favorites URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[String], Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    print("[INFO] User favorites fetched successfully")
                    completion(.success(response))
                case .failure(let error):
                    print("[ERROR] [FavoritesService/getFavorites] Failed to fetch user favorites with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to fetch user favorites with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
}

import Foundation

protocol RestrictionsServiceProtocol {
    func getUserRestrictions(for token: String, completion: @escaping (Result<[Restriction], Error>) -> Void)
}

final class RestrictionsService: RestrictionsServiceProtocol {
    static let shared = RestrictionsService()
    
    private(set) var userRestrictions: [Restriction]?
    
    private init() {}
    
    func getUserRestrictions(for token: String, completion: @escaping (Result<[Restriction], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.userRestrictionsRoute) else {
            print( "[ERROR] [RestrictionsService/getUserRestrictions] Failed to create URL")
            completion(.failure(NetworkError.message("Failed to create URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[RestrictionResponseBody], Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    var restrictions: [Restriction] = []
                    for restriction in response {
                        restrictions.append(Restriction(from: restriction))
                    }
                    self.userRestrictions = restrictions
                    completion(.success(restrictions))
                    print("[INFO] User restrictions loaded successfully")
                case .failure(let error):
                    print("[ERROR] [RestrictionsService/getUserRestrictions] Failed to load user restrictions with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to load user restrictions with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
}

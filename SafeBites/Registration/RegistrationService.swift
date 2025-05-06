import Foundation

protocol RegistrationServiceProtocol {
    var user: User? { get }
    func register(email: String, password: String, name: String?, completion: @escaping (Result<User, Error>) -> Void)
}

final class RegistrationService {
    static let shared = RegistrationService()
    
    private(set) var user: User?
    
    private init() {}
    
    func register(email: String, password: String, name: String?, completion: @escaping (Result<User, Error>) -> Void) {
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.registerRoute) else {
            print("[ERROR] [RegistrationService/register] Failed to create register URL")
            completion(.failure(NetworkError.message("Failed to create register URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "login": email,
            "password": password,
            "name": name ?? ""
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch(let error) {
            print("[ERROR] [RegistrationService/register] Failed to serialize request body with error: \(error)")
            completion(.failure(NetworkError.message("Failed to serialize registration request body with error: \(error)")))
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    let user = User(from: response)
                    self.user = user
                    completion(.success(user))
                    print("[INFO] User loaded successfully")
                case .failure(let error):
                    print("[ERROR] [RegistrationService/register] Failed to load user with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to load user with error: \(error)")))
                }
            }
        }
        
        task.resume()
    }
}

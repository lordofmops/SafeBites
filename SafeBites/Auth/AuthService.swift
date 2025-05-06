import Foundation

final class AuthService {
    static let shared = AuthService()
    
    private let authTokenStorage = AuthTokenStorage.shared
    private let authTokenKey = "authToken"
    
    private init() {}
    
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.loginRoute) else {
            print("[ERROR] [AuthService/login]: Failed to create URLComponents")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let requestBody = ["login": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch(let error) {
            print("[ERROR] [AuthService/login] Failed to serialize request body: \(error)")
        }
        
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<AuthResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    let token = response.token
                    self.authTokenStorage.token = token
                    completion(.success((token)))
                    print("[INFO] Auth token fetched: \(token)")
                case .failure(let error):
                    print("[ERROR] [AuthService/login] Failed to fetch auth token: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

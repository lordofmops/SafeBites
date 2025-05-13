import Foundation

protocol ProfileServiceProtocol {
    var user: User? { get }
    func fetchProfile(token: String, completion: @escaping (Result<User, Error>) -> Void)
    func updateName(token: String, updatedName: String, completion: @escaping (Result<User, any Error>) -> Void)
    func deleteProfile(token: String, completion: @escaping (Result<Void, any Error>) -> Void)
    func addRestriction(id: UUID, token: String, completion: @escaping (Result<[Restriction], Error>) -> Void)
    func removeRestriction(id: UUID, token: String, completion: @escaping (Result<[Restriction], Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    
    var user: User?
    var restrictions: [Restriction]?
    
    private init() {}
    
    func fetchProfile(token: String, completion: @escaping (Result<User, any Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.profileRoute) else {
            print("[ERROR] [ProfileService/fetchProfile] Failed to create profile URL")
            completion(.failure(NetworkError.message("Failed to create profile URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    var user = User(from: response)
                    
                    completion(.success(user))
                    print("[INFO] User profile loaded successfully")
                case .failure(let error):
                    print("[ERROR] [ProfileService/fetchProfile] Failed to load user profile with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to load user profile with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
    
    func updateName(token: String, updatedName: String, completion: @escaping (Result<User, any Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.profileRoute) else {
            print("[ERROR] [ProfileService/updateName] Failed to create profile URL")
            completion(.failure(NetworkError.message("Failed to create profile URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "name": updatedName
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch(let error) {
            print("[ERROR] [ProfileService/updateName] Failed to serialize request body with error: \(error)")
            completion(.failure(NetworkError.message("Failed to serialize registration request body with error: \(error)")))
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    var user = User(from: response)
                    
                    completion(.success(user))
                    print("[INFO] Username updated successfully")
                case .failure(let error):
                    print("[ERROR] [ProfileService/updateName] Failed to update username with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to update username with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
    
    func deleteProfile(token: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.profileRoute) else {
            print("[ERROR] [ProfileService/updateName] Failed to create profile URL")
            completion(.failure(NetworkError.message("Failed to create profile URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<String, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    print("[INFO] User profile deleted successfully")
                    completion(.success(()))
                case .failure(let error):
                    print("[ERROR] [ProfileService/deleteProfile] Failed to delete user profile with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to delete user profile with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
    
    func addRestriction(id: UUID, token: String, completion: @escaping (Result<[Restriction], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.userRestrictionsRoute) else {
            print("[ERROR] [ProfileService/addRestriction] Failed to create restriction URL")
            completion(.failure(NetworkError.message("Failed to create restriction URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "restriction_id": id
        ]
        do {
            request.httpBody = try JSONEncoder().encode(["restriction_id": id])
        } catch(let error) {
            print("[ERROR] [ProfileService/addRestriction] Failed to serialize request body with error: \(error)")
            completion(.failure(NetworkError.message("Failed to serialize registration request body with error: \(error)")))
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[RestrictionResponseBody], Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    var restrictions: [Restriction] = []
                    for restriction in response {
                        restrictions.append(Restriction(from: restriction))
                    }
                    self.restrictions = restrictions
                    print("[INFO] User restriction added successfully")
                    completion(.success(restrictions))
                case .failure(let error):
                    print("[ERROR] [ProfileService/addRestriction] Failed to add user restriction with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to add user restriction with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
    
    func removeRestriction(id: UUID, token: String, completion: @escaping (Result<[Restriction], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let url = URL(string: Constants.defaultBaseApiUrl + Constants.userRestrictionsRoute + id.uuidString) else {
            print("[ERROR] [ProfileService/removeRestriction] Failed to create restriction URL")
            completion(.failure(NetworkError.message("Failed to create restriction URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
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
                    self.restrictions = restrictions
                    print("[INFO] User restriction removed successfully")
                    completion(.success(restrictions))
                case .failure(let error):
                    print("[ERROR] [ProfileService/removeRestriction] Failed to remove user restriction with error: \(error)")
                    completion(.failure(NetworkError.message("Failed to remove user restriction with error: \(error.localizedDescription)")))
                }
            }
        }
        
        task.resume()
    }
}

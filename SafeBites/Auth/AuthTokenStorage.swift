import Foundation
import SwiftKeychainWrapper

final class AuthTokenStorage {
    static let shared = AuthTokenStorage()
    
    private init() {}
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "auth_token")
        }
        set {
            if let newValue {
                print(
                    KeychainWrapper.standard.set(newValue, forKey: "auth_token")
                    ? "[INFO] Auth token successfully saved"
                    : "[ERROR] [AuthTokenStorage/token] Failed to save auth token"
                )
            } else {
                print(
                    KeychainWrapper.standard.removeObject(forKey: "auth_token")
                    ? "[INFO] Auth token successfully removed"
                    : "[ERROR] [AuthTokenStorage/token] Failed to remove auth token"
                )
            }
        }
    }
    
    func deleteToken() {
        self.token = nil
    }
}

import Foundation

struct UserResponseBody: Decodable {
    let id: UUID
    let login: String
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
    }
}

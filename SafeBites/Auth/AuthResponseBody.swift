import Foundation

struct AuthResponseBody: Decodable {
    let token: String

    enum CodingKeys: String, CodingKey {
        case token = "token"
    }
}

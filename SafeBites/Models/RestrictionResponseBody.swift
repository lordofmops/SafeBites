import Foundation

struct RestrictionResponseBody: Decodable {
    let id: UUID
    let name: String
    let type: String
    let tag: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case tag
    }
}

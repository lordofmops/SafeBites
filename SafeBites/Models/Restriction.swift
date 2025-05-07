import Foundation

struct Restriction {
    let id: UUID
    let name: String
    let type: String
    let tag: String
}

extension Restriction {
    init(from restrictionResponseBody: RestrictionResponseBody) {
        self.id = restrictionResponseBody.id
        self.name = restrictionResponseBody.name
        self.type = restrictionResponseBody.type
        self.tag = restrictionResponseBody.tag
    }
}

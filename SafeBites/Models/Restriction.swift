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

enum StaticRestrictions {
    static let all: [Restriction] = [
        Restriction(id: UUID(uuidString: "572f0329-6dee-4dce-b309-7a91e2d8a2da")!, name: "Молоко", type: "allergen", tag: "milk"),
        Restriction(id: UUID(uuidString: "057e48ee-d688-4efe-867d-253746233dab")!, name: "Орехи", type: "allergen", tag: "nuts"),
        Restriction(id: UUID(uuidString: "5f44fe7d-6d4a-44f4-b721-c7c10eee8dc5")!, name: "Соя", type: "allergen", tag: "soybeans"),
        Restriction(id: UUID(uuidString: "2fc42ff2-122c-41ad-bfcd-ffa3c8a1c7ff")!, name: "Веганство", type: "diet", tag: "vegan"),
        Restriction(id: UUID(uuidString: "4a90df21-5776-4dfc-b6fe-714d53b8244a")!, name: "Вегетарианство", type: "diet", tag: "vegetarian")
    ]
}

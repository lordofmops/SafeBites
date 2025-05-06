import Foundation

struct User {
    let id: UUID
    let email: String
    let name: String?
}

extension User {
    init(from userResponseBody: UserResponseBody) {
        self.id = userResponseBody.id
        self.email = userResponseBody.login
        self.name = userResponseBody.name
    }
}

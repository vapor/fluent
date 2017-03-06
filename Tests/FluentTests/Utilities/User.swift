import Fluent

final class User: Entity {
    let storage = Storage()
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(self) { builder in
            builder.id(for: self)
            builder.string("name")
            builder.string("email")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(self)
    }

    var name: String
    var email: String

    init(id: Node?, name: String, email: String) {
        self.name = name
        self.email = email
        self.id = id
    }

    init(node: Node) throws {
        name = try node.get("name")
        email = try node.get("email")
        id = try node.get(idKey)
    }

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            idKey: id,
            "name": name,
            "email": email
        ])
    }
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
    }
}

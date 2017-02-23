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

    init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        email = try node.extract("email")
        id = try node.extract(idKey)
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
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

import Fluent

final class User: Entity {
    var exists: Bool = false
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id(idKey)
            builder.string("name")
            builder.string("email")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }

    var id: Fluent.Node?
    var name: String
    var email: String

    init(id: Node?, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract(type(of: self).idKey)
        name = try node.extract("name")
        email = try node.extract("email")
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            type(of: self).idKey: id,
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

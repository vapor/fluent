import Fluent

final class User: Entity {
    var id: Fluent.Node?
    var name: String
    var email: String

    init(id: Node?, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    func makeNode() -> Node {
        return Node([
            "id": id,
            "name": name,
            "email": email
        ])
    }

    init(_ node: Node) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email")
    }

    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
            builder.string("email")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
}

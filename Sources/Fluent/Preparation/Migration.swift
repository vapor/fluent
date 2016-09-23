final class Migration: Entity {
    static var entity = "fluent"
    var exists: Bool = false

    var id: Node?
    var name: String

    init(name: String) {
        self.name = name
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

import Fluent

final class Compound: Entity {
    var id: Node?
    var name: String
    var exists: Bool = false

    init(name: String) {
        self.name = name
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract(type(of: self).idKey)
        name = try node.extract("name")
    }

    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
        ])
    }

    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id(for: self)
            builder.string("name")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
}

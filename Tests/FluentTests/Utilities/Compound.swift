import Fluent

final class Compound: Entity {
    var name: String
    let storage = Storage()

    init(name: String) {
        self.name = name
    }

    init(node: Node) throws {
        name = try node.get("name")
        id = try node.get(idKey)
    }

    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            idKey: id,
            "name": name
        ])
    }

    static func prepare(_ database: Fluent.Database) throws {
        try database.create(self) { builder in
            builder.id(for: self)
            builder.string("name")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(self)
    }
}

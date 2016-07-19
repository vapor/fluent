final class Migration: Entity {
    static var entity = "fluent"

    var id: Node?
    var name: String

    init(name: String) {
        self.name = name
    }

    init(_ node: Node) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }

    func makeNode() -> Node {
        return Node([
            "id": id,
            "name": name
        ])
    }

    static func prepare(database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
        }
    }

    static func revert(database: Database) throws {
        try database.delete(entity)
    }
}

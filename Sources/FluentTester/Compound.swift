import Fluent

public final class Compound: Entity {
    public var id: Node?
    public var name: String
    public var exists = false

    public init(id: Node?, name: String) {
        self.id = id
        self.name = name
    }

    public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
        ])
    }

    public func atoms() throws -> Siblings<Atom> {
        return try siblings()
    }

    public static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id(for: self)
            builder.string("name")
        }
    }

    public static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
}

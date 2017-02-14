import Fluent

public final class Compound: Entity {
    public var name: String
    public let storage = Storage()

    public init(id: Node?, name: String) {
        self.name = name
        self.id = id
    }

    public init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        id = try node.extract(idKey)
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            idKey: id,
            "name": name
        ])
    }

    public func atoms() throws -> Siblings<Compound, Atom> {
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

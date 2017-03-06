public final class Compound: Entity {
    public var name: String
    public let storage = Storage()

    public init(id: Node?, name: String) {
        self.name = name
        self.id = id
    }

    public init(node: Node) throws {
        name = try node.get("name")
        id = try node.get(idKey)
    }

    public func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            idKey: id ?? nil,
            "name": name
        ])
    }

    var atoms: Siblings<Compound, Atom, Pivot<Compound, Atom>> {
        return siblings()
    }

    // wish this would work!
    // lazy var atoms = Siblings(from: self, to: Atom.self, through: Pivot<Compound, Atom>.self)

    public static func prepare(_ database: Fluent.Database) throws {
        try database.create(self) { builder in
            builder.id(for: self)
            builder.string("name")
        }
    }

    public static func revert(_ database: Fluent.Database) throws {
        try database.delete(self)
    }
}

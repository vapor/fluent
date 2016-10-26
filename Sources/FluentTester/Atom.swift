import Fluent

public final class Atom: Entity {
    public var id: Node?

    public var name: String
    public var protons: Int
    public var weight: Double

    public var exists: Bool = false

    public init(id: Node?, name: String, protons: Int, weight: Double) {
        self.id = id
        self.name = name
        self.protons = protons
        self.weight = weight
    }

    public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        protons = try node.extract("protons")
        weight = try node.extract("weight")
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "protons": protons,
            "weight": weight
        ])
    }

    public func compounds() throws -> Siblings<Compound> {
        return try siblings()
    }

    public static func prepare(_ database: Database) throws {
        try database.create(entity) { atoms in
            atoms.id()
            atoms.string("name")
            atoms.int("protons")
            atoms.double("weight")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

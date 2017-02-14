import Fluent

public final class Atom: Entity {
    public var name: String
    public var protons: Int
    public var weight: Double

    public let storage = Storage()

    public init(id: Node?, name: String, protons: Int, weight: Double) {
        self.name = name
        self.protons = protons
        self.weight = weight

        self.set(id: id)
    }

    public init(node: Node, in context: Context) throws {
        name = try node.extract("name")
        protons = try node.extract("protons")
        weight = try node.extract("weight")

        set(id: node)
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            type(of: self).idKey: id,
            "name": name,
            "protons": protons,
            "weight": weight
        ])
    }

    public func compounds() throws -> Siblings<Atom, Compound> {
        return try siblings()
    }

    public static func prepare(_ database: Database) throws {
        try database.create(entity) { atoms in
            atoms.id(for: self)
            atoms.string("name")
            atoms.int("protons")
            atoms.double("weight")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

public final class Atom: Entity {
    public var name: String
    public var protons: Int
    public var weight: Double

    public let storage = Storage()

    public init(id: Node?, name: String, protons: Int, weight: Double) {
        self.name = name
        self.protons = protons
        self.weight = weight
        self.id = id
    }

    public init(node: Node) throws {
        name = try node.get("name")
        protons = try node.get("protons")
        weight = try node.get("weight")

        id = try node.get(idKey)
    }

    public func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            idKey: id ?? nil,
            "name": name,
            "protons": protons,
            "weight": weight
        ])
    }

    var compounds: Siblings<Atom, Compound, Pivot<Atom, Compound>> {
        return siblings()
    }

    public static func prepare(_ database: Database) throws {
        try database.create(self) { atoms in
            atoms.id(for: self)
            atoms.string("name")
            atoms.int("protons")
            atoms.double("weight")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

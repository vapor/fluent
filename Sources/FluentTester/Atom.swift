public final class Atom: Entity {
    public var name: String
    public var protons: Int
    public var weight: Double

    public let storage = Storage()

    public init(id: Identifier?, name: String, protons: Int, weight: Double) {
        self.name = name
        self.protons = protons
        self.weight = weight
        self.id = id
    }

    public init(row: Row) throws {
        name = try row.get("name")
        protons = try row.get("protons")
        weight = try row.get("weight")
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("protons", protons)
        try row.set("weight", weight)
        return row
    }

    var compounds: Siblings<Atom, Compound, Pivot<Atom, Compound>> {
        return siblings()
    }

    public static func prepare(_ database: Database) throws {
        try database.create(self) { atoms in
            atoms.id()
            atoms.string("name")
            atoms.int("protons")
            atoms.double("weight")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

public final class Compound: Entity {
    public var name: String
    public let storage = Storage()

    public init(id: Identifier?, name: String) {
        self.name = name
        self.id = id
    }

    public init(row: Row) throws {
        name = try row.get("name")
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(idKey, id)
        try row.set("name", name)
        return row
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

public final class Compound: Entity {
    public var name: String
    public let storage = Storage()

    public init(id: Identifier? = nil, name: String) {
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

extension Compound: Paginatable {
    public static var pageSize: Int {
        return 2
    }

    public static var pageSorts: [Sort] {
        return [
            Sort(self, "name", .ascending)
        ]
    }
}

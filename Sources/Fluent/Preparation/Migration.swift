final class Migration: Entity {
    static var entity = "fluent"
    let storage = Storage()
    var name: String

    init(name: String) {
        self.name = name
    }

    init(row: Row) throws {
        name = try row.get("name")
        id = try row.get(idKey)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(idKey, id)
        try row.set("name", name)
        return row
    }

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id(for: self)
            builder.string("name")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

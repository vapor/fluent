import Fluent

final class Group: Entity {
    let storage = Storage()
    init(row: Row) throws {}
    func makeRow() -> Row { return .null }
    static func prepare(_ database: Database) throws {
        try database.create(self) { groups in
            groups.id(for: self)
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

import Fluent

final class Group: Entity {
    let storage = Storage()
    init(node: Node) throws {}

    func makeNode(in context: Context?) -> Node { return .null }
    static func prepare(_ database: Database) throws {
        try database.create(self) { groups in
            groups.id(for: self)
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

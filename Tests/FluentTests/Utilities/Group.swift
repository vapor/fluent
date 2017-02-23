import Fluent

final class Group: Entity {
    let storage = Storage()
    init(node: Node, in context: Context) throws {}

    func makeNode(context: Context = EmptyNode) -> Node { return .null }
    static func prepare(_ database: Database) throws {
        try database.create(self) { groups in
            groups.id(for: self)
        }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

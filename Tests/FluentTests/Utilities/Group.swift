import Fluent

final class Group: Entity {
    var id: Node?
    init(node: Node, in context: Context) throws {}

    func makeNode() -> Node { return .null }
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}

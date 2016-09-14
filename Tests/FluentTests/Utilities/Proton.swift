import Fluent

final class Proton: Entity {
    var id: Node?
    init(node: Node, in context: Context) throws {}

    func makeNode(context: Context = EmptyNode) -> Node { return .null }
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}

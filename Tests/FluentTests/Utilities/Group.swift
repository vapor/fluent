import Fluent

final class Group: Entity {
    var id: Node?
    var exists: Bool = false
    
    static func fields(for database: Database) -> [String] { return [] }
    
    init(node: Node, in context: Context) throws {}
    func makeNode(context: Context = EmptyNode) -> Node { return .null }
    
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}

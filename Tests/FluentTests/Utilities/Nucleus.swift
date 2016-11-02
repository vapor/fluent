import Fluent

final class Nucleus: Entity {
    var exists: Bool = false
    static var entity = "nuclei"
    var id: Node?
    
    static func fields(for database: Database) -> [String] { return [] }
    
    init(node: Node, in context: Context) throws { }
    func makeNode(context: Context = EmptyNode) -> Node { return .null }
    
    static func prepare(_ database: Database) throws {}
    static func revert(_ database: Database) throws {}
}

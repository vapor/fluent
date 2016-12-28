import Fluent

struct CustomId: Entity {
    var exists: Bool = false
    
    static var idKey: String? {
        return "custom_id"
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("label")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
    var id: Fluent.Node?
    var label: String
    
    init(id: Node?, label: String) {
        self.id = id
        self.label = label
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("custom_id")
        label = try node.extract("label")
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            "custom_id": id,
            "label": label,
        ])
    }
}

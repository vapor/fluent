import Fluent

struct CustomIdKey: Entity {
    let storage = Storage()
    
    static var idKey: String {
        return "custom_id"
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id(idKey)
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
        id = try node.extract(type(of: self).idKey)
        label = try node.extract("label")
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            type(of: self).idKey: id,
            "label": label,
        ])
    }
}

import Fluent

final class CustomIdKey: Entity {
    let storage = Storage()
    
    static var idKey: String {
        return "custom_id"
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(entity) { builder in
            builder.id(for: CustomIdKey.self)
            builder.string("label")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(entity)
    }
    
    var label: String
    
    init(id: Node?, label: String) {
        self.label = label
        self.id = id
    }
    
    init(node: Node, in context: Context) throws {
        label = try node.extract("label")
        id = try node.extract(type(of: self).idKey)
    }
    
    func makeNode(context: Context = EmptyNode) throws -> Node {
        return try Node(node: [
            type(of: self).idKey: id,
            "label": label,
        ])
    }
}

import Fluent

final class CustomIdKey: Entity {
    let storage = Storage()
    
    static var idKey: String {
        return "custom_id"
    }
    
    static func prepare(_ database: Fluent.Database) throws {
        try database.create(self) { builder in
            builder.id(for: CustomIdKey.self)
            builder.string("label")
        }
    }
    static func revert(_ database: Fluent.Database) throws {
        try database.delete(self)
    }
    
    var label: String
    
    init(id: Node?, label: String) {
        self.label = label
        self.id = id
    }
    
    init(node: Node) throws {
        label = try node.get("label")
        id = try node.get(idKey)
    }
    
    func makeNode(in context: Context?) throws -> Node {
        return try Node(node: [
            idKey: id,
            "label": label,
        ])
    }
}

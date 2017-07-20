import Node

/// Conforms Filter to NodeRepresentable and adds a Node Initializer
extension Filter: NodeRepresentable {
    public init(_ entity: Entity.Type, _ node: Node) throws {
        self.method = try Method(entity, node)
        self.entity = entity
    }

    public func makeNode(in context: Context?) throws -> Node {
        return try self.method.makeNode(in: context)
    }
}

enum FilterSerializationError: Error {
    case undefinedComparison(String)
    case undefinedScope(String)
    case undefinedRelation(String)
    case undefinedMethodType(String)
}

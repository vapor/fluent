import Foundation
import Node

/// Conforms Filter to NodeRepresentable and adds a Node Initializer
extension Filter: NodeConvertible {
    public init(node: Node) throws {
        let entityName: String = try node.get("entity")
        let entityClass: AnyClass? = NSClassFromString(entityName)
        guard let entity = entityClass as? Entity.Type else {
            throw FilterSerializationError.undefinedEntity(entityName)
        }

        self.entity = entity
        self.method = try Method(node: try node.get("method"))
    }

    public func makeNode(in context: Context?) throws -> Node {
        return try self.method.makeNode(in: context)
    }
}

enum FilterSerializationError: Error {
    case undefinedEntity(String)
    case undefinedComparison(String)
    case undefinedScope(String)
    case undefinedRelation(String)
    case undefinedMethodType(String)
}

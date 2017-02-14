/// A basic Pivot using two entities:
/// left and right.
/// The pivot itself conforms to entity
/// and can be used like any other Fluent model
/// in preparations, querying, etc.
public final class Pivot<
    L: Relatable,
    R: Relatable
>: PivotProtocol, Entity {
    public typealias Left = L
    public typealias Right = R

    public static var entity: String {
        if Left.name < Right.name {
            return "\(Left.name)_\(Right.name)"
        } else {
            return "\(Right.name)_\(Left.name)"
        }
    }

    public static var name: String {
        return entity
    }

    public var id: Node?
    public var leftId: Node?
    public var rightId: Node?
    public var exists = false

    public init(_ left: Entity, _ right: Entity) {
        leftId = left.id
        rightId = right.id
    }

    public init(node: Node, in context: Context) throws {
        id = try node.extract(type(of: self).idKey)

        leftId = try node.extract(Left.foreignIdKey)
        rightId = try node.extract(Right.foreignIdKey)
    }

    public func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            type(of: self).idKey: id,
            Left.foreignIdKey: leftId,
            Right.foreignIdKey: rightId,
        ])
    }

    public static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id(for: self)
            builder.foreignId(for: Left.self)
            builder.foreignId(for: Right.self)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

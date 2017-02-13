public final class BasicPivot<
    L: Entity,
    R: Entity
>: Pivot, Entity {
    public typealias Left = L
    public typealias Right = R

    public var exists: Bool = false

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
            builder.id(for: Left.self, name: Left.foreignIdKey)
            builder.id(for: Right.self, name: Right.foreignIdKey)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

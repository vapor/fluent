public final class Pivot<
    L: Entity,
    R: Entity
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

// MARK: Double Pivot

extension Pivot where L: PivotProtocol {
    public static func related(
        left: Left.Left,
        middle: Left.Right,
        right: Right
    ) throws -> Bool {
        let (leftId, middleId, rightId) = try assertIdsExist(left, middle, right)

        let result = try Left
            .query()
            .union(
                self,
                localKey: Left.idKey,
                foreignKey: Left.foreignIdKey
            )
            .filter(Left.self, Left.Left.foreignIdKey, leftId)
            .filter(Left.self, Left.Right.foreignIdKey, middleId)
            .filter(self, Right.foreignIdKey, rightId)
            .first()

        return result != nil
    }
}

extension Pivot where R: PivotProtocol {
    public static func related(
        left: Left,
        middle: Right.Left,
        right: Right.Right
    ) throws -> Bool {
        let (leftId, middleId, rightId) = try assertIdsExist(left, middle, right)

        let result = try Right
            .query()
            .union(
                self,
                localKey: Right.idKey,
                foreignKey: Right.foreignIdKey
            )
            .filter(self, Left.foreignIdKey, leftId)
            .filter(Right.self, Right.Left.foreignIdKey, middleId)
            .filter(Right.self, Right.Right.foreignIdKey, rightId)
            .first()

        return result != nil
    }
}

private func assertIdsExist(
    _ left: Entity,
    _ middle: Entity,
    _ right: Entity
) throws -> (Node, Node, Node) {
    guard let leftId = left.id else {
        throw PivotError.leftIdRequired
    }

    guard let middleId = middle.id else {
        throw PivotError.middleIdRequired
    }

    guard let rightId = right.id else {
        throw PivotError.rightIdRequired
    }

    return (leftId, middleId, rightId)
}

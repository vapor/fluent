/// A pivot between two many-to-many
/// database entities.
///
/// For example: users > users+teams < teams
///
/// let teams = users.teams()
public protocol PivotProtocol {
    associatedtype Left: Entity
    associatedtype Right: Entity

    /// Returns true if the two entities are related
    static func related(_ left: Left, _ right: Right) throws -> Bool

    /// Attaches the two entities
    /// Entities must be saved before attempting attach.
    @discardableResult
    static func attach(_ left: Left, _ right: Right) throws -> Self

    /// Detaches the two entities.
    /// Entities must be saved before attempting detach.
    static func detach(_ left: Left, _ right: Right) throws
}

/// PivotProtocol methods that come
/// pre-implemented if the Pivot conforms to Entity
extension PivotProtocol where Self: Entity {
    /// See PivotProtocol.related
    public static func related(_ left: Left, _ right: Right) throws -> Bool {
        let (leftId, rightId) = try assertSaved(left, right)

        let results = try query()
            .filter(type(of: left).foreignIdKey, leftId)
            .filter(type(of: right).foreignIdKey, rightId)
            .first()

        return results != nil
    }

    /// See PivotProtocol.attach
    public static func attach(_ left: Left, _ right: Right) throws -> Self {
        _ = try assertSaved(left, right)

        let pivot = try self.init(node: [
            Left.foreignIdKey: left.id,
            Right.foreignIdKey: right.id
        ])
        try pivot.save()

        return pivot
    }

    /// See PivotProtocol.detach
    public static func detach(_ left: Left, _ right: Right) throws {
        let (leftId, rightId) = try assertSaved(left, right)

        try query()
            .filter(Left.foreignIdKey, leftId)
            .filter(Right.foreignIdKey, rightId)
            .delete()
    }
}

// MARK: Convenience

private func assertSaved(_ left: Entity, _ right: Entity) throws -> (Node, Node) {
    guard left.exists else {
        throw PivotError.existRequired(left)
    }

    guard let leftId = left.id else {
        throw PivotError.idRequired(left)
    }

    guard right.exists else {
        throw PivotError.existRequired(right)
    }

    guard let rightId = right.id else {
        throw PivotError.idRequired(right)
    }

    return (leftId, rightId)
}

/// A pivot between two many-to-many
/// database entities.
///
/// For example: users > users+teams < teams
///
/// let teams = users.teams()
public protocol PivotProtocol {
    associatedtype Left: Relatable
    associatedtype Right: Relatable
}

/// PivotProtocol methods that come
/// pre-implemented if the Pivot conforms to Entity
extension PivotProtocol
    where
        Self: Entity,
        Left: Entity,
        Right: Entity
{
    /// See PivotProtocol.related
    public static func related(_ left: Left, _ right: Right) throws -> Bool {
        let (leftId, rightId) = try assertIdsExist(left, right)

        let results = try query()
            .filter(type(of: left).foreignIdKey, leftId)
            .filter(type(of: right).foreignIdKey, rightId)
            .first()

        return results != nil
    }

    /// See PivotProtocol.attach
    public static func attach(_ left: Left, _ right: Right) throws {
        _ = try assertIdsExist(left, right)

        var pivot = Pivot<Left, Right>(left, right)
        try pivot.save()
    }

    /// See PivotProtocol.detach
    public static func detach(_ left: Left, _ right: Right) throws {
        let (leftId, rightId) = try assertIdsExist(left, right)

        try query()
            .filter(Left.foreignIdKey, leftId)
            .filter(Right.foreignIdKey, rightId)
            .delete()
    }
}

// MARK: Convenience

private func assertIdsExist(_ left: Entity, _ right: Entity) throws -> (Node, Node) {
    guard let leftId = left.id else {
        throw PivotError.idRequired(left)
    }

    guard let rightId = right.id else {
        throw PivotError.idRequired(right)
    }

    return (leftId, rightId)
}

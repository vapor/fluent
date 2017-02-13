/// A pivot between two many-to-many
/// database entities.
///
/// For example: users > users+teams < teams
///
/// let teams = users.teams()
public protocol PivotProtocol {
    associatedtype Left: Entity
    associatedtype Right: Entity

    /// Returns true if the two entities 
    /// are related by the pivot.
    static func related(_: Left, _: Right) throws -> Bool

    /// Attaches the two entities, relating them.
    static func attach(_: Left, _: Right) throws

    /// Detaches the three related entities.
    static func detach(_: Left, _: Right) throws
}

/// Errors that can be thrown while
/// attempting to attach, detach, or
/// check the relation on pivots.
public enum PivotError: Error {
    case leftIdRequired
    case middleIdRequired
    case rightIdRequired
    case unspecified(Error)
}

/// PivotProtocol methods that come
/// pre-implemented if the Pivot conforms to Entity
extension PivotProtocol where Self: Entity {
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
        throw PivotError.leftIdRequired
    }

    guard let rightId = right.id else {
        throw PivotError.rightIdRequired
    }

    return (leftId, rightId)
}

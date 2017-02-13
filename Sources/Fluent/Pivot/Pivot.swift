/// A pivot between two many-to-many
/// database entities.
///
/// For example: users > users+teams < teams
///
/// let teams = users.teams()
public protocol Pivot {
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

public enum PivotError: Error {
    case leftIdRequired
    case rightIdRequired
    case unspecified(Error)
}

extension BasicPivot {
    public static func related(_ left: Left, _ right: Right) throws -> Bool {
        let (leftId, rightId) = try assertIdsExist(left, right)

        let results = try query()
            .filter(type(of: left).foreignIdKey, leftId)
            .filter(type(of: right).foreignIdKey, rightId)
            .first()

        return results != nil
    }


    public static func attach(_ left: Left, _ right: Right) throws {
        _ = try assertIdsExist(left, right)

        var pivot = BasicPivot(left, right)
        try pivot.save()
    }

    public static func detach(_ left: Left, _ right: Right) throws {
        let (leftId, rightId) = try assertIdsExist(left, right)

        try query()
            .filter(Left.foreignIdKey, leftId)
            .filter(Right.foreignIdKey, rightId)
            .delete()
    }

    private static func assertIdsExist(_ left: Left, _ right: Right) throws -> (Node, Node) {
        guard let leftId = left.id else {
            throw PivotError.leftIdRequired
        }

        guard let rightId = right.id else {
            throw PivotError.rightIdRequired
        }

        return (leftId, rightId)
    }
}

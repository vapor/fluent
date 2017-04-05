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
        let leftId = try left.assertExists()
        let rightId = try right.assertExists()

        let results = try makeQuery()
            .filter(type(of: left).foreignIdKey, leftId)
            .filter(type(of: right).foreignIdKey, rightId)
            .first()

        return results != nil
    }

    /// See PivotProtocol.attach
    @discardableResult
    public static func attach(_ left: Left, _ right: Right) throws -> Self {
        let leftId = try left.assertExists()
        let rightId = try right.assertExists()

        var row = Row()
        try row.set(Left.foreignIdKey, leftId)
        try row.set(Right.foreignIdKey, rightId)

        let pivot = try self.init(row: row)
        try pivot.save()

        return pivot
    }

    /// See PivotProtocol.detach
    public static func detach(_ left: Left, _ right: Right) throws {
        let leftId = try left.assertExists()
        let rightId = try right.assertExists()

        try makeQuery()
            .filter(Left.foreignIdKey, leftId)
            .filter(Right.foreignIdKey, rightId)
            .delete()
    }
}

/// A pivot between three many-to-many
/// database entities.
///
/// For example: users > users+teams < teams
///                           ^
///              users+teams+team_permissions
///                           V
///                    team_permissions
///
///
/// let permissions = users.permissions(for: team)
public protocol TriplePivot {
    associatedtype Left: Entity
    associatedtype Middle: Entity
    associatedtype Right: Entity

    /// Returns true if the three entities
    /// are related by the pivot.
    static func related(
        left: Left,
        middle: Middle,
        right: Right
    ) throws -> Bool

    /// Attaches the three entities, relating them.
    static func attach(
        left: Left,
        middle: Middle,
        right: Right
    ) throws

    /// Detaches the three related entities.
    static func detach(
        left: Left,
        middle: Middle,
        right: Right
    ) throws
}

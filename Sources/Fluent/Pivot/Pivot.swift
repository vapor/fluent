/// The string to use when connecting entity names for pivot tables.
///
/// A pivot name connector of `"_"` would derive the following name for a pivot on `Pet` and `User`.
///
///     pet_user
///
/// You can change the `pivotNameConnector` by updating the global variable.
///
///     Fluent.pivotNameConnector = "+"
///
/// Note: Changing the `pivotNameConnector` requires that you also update any pivot tables in your database.
public var pivotNameConnector: String = "_"

/// Capable of being a pivot between two
/// models. Usually in a Siblings relation.
/// note: special care must be taken when using pivots
/// with equal left and right types.
public protocol Pivot: Model {
    /// The Left model for this pivot.
    /// note: a pivot with opposite right/left is distinct.
    associatedtype Left: Model

    /// The Right model for this pivot.
    /// note: a pivot with opposite right/left is distinct.
    associatedtype Right: Model

    /// Key path type for left id key
    typealias LeftIDKey = WritableKeyPath<Self, Left.ID>

    /// Key for accessing left id
    static var leftIDKey: LeftIDKey { get }

    /// Key path type for right id key
    typealias RightIDKey = WritableKeyPath<Self, Right.ID>

    /// Key for accessing right id
    static var rightIDKey: RightIDKey { get }
}

/// A pivot that can be initialized from just
/// the left and right models. This allows
/// Fluent to automatically create pivots for
/// extended functionality.
/// ex: attach
/// note: pivots with equal left and right types
/// cannot take advantage of this protocol due to
/// ambiguous type errors.
public protocol ModifiablePivot: Pivot {
    init(_ left: Left, _ right: Right) throws
}

extension Pivot {
    /// See Model.entity
    public static var name: String {
        if Left.name < Right.name {
            return Left.name + pivotNameConnector + Right.name
        } else {
            return Right.name + pivotNameConnector + Left.name
        }
    }

    /// See Model.entity
    public static var entity: String {
        return name
    }
}

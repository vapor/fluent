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
/// - note: Changing the `pivotNameConnector` requires that you also update any pivot tables in your database.
public var pivotNameConnector: String = "_"

/// Capable of being a pivot between two models. Usually in a `Siblings` relation.
///
///     final class UserPet: Pivot {
///         typealias Left = User
///         typealias Right = Pet
///         static let leftIDKey: LeftIDKey = \.userID
///         static let rightIDKey: RightIDKey = \.petID
///
///         var userID: Int
///         var petID: Int
///     }
///
/// A pivot is responsible for declaring which two models types it relates and its stored properties
/// that reference those model's identifiers.
///
/// See `ModifiablePivot` to enable Fluent to create instances of your pivot.
public protocol Pivot: Model {
    /// The Left model for this pivot.
    associatedtype Left: Model

    /// The Right model for this pivot.
    associatedtype Right: Model

    /// Key path type for left id key.
    typealias LeftIDKey = WritableKeyPath<Self, Left.ID>

    /// Key for accessing left id.
    static var leftIDKey: LeftIDKey { get }

    /// Key path type for right id key.
    typealias RightIDKey = WritableKeyPath<Self, Right.ID>

    /// Key for accessing right id.
    static var rightIDKey: RightIDKey { get }
}

extension Pivot {
    /// See `Model`.
    public static var name: String {
        if Left.name < Right.name {
            return Left.name + pivotNameConnector + Right.name
        } else {
            return Right.name + pivotNameConnector + Left.name
        }
    }
    
    /// See `Model`.
    public static var entity: String {
        return name
    }
}

/// A pivot that can be initialized from just the left and right models. This allows
/// Fluent to automatically create pivots for extended functionality. ex: attaching.
public protocol ModifiablePivot: Pivot {
    init(_ left: Left, _ right: Right) throws
}

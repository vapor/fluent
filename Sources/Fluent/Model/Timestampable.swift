/// Stores timestamps representing when this model was first created and when it was last updated.
/// Fluent automatically updates these timestamps whenever changes to the database are made.
///
///     final class User: Model {
///         ...
///         var createdAt: Date?
///         var updatedAt: Date?
///     }
///
///     extension User: Timestampable {
///         static let createdAtKey: CreatedAtKey = \.createdAt
///         static let updatedAtKey: UpdatedAtKey = \.updatedAt
///     }
///
/// You can add `Timestampable` to existing models that has two optional `Date` properties for storing the
/// created at and updated at dates.
public protocol Timestampable: AnyTimestampable {
    /// Swift `KeyPath` referencing created at property.
    typealias CreatedAtKey = WritableKeyPath<Self, Date?>

    /// Swift `KeyPath` referencing updated at property.
    typealias UpdatedAtKey = WritableKeyPath<Self, Date?>

    /// The date at which this model was created.
    /// `nil` if the model has not been created yet.
    static var createdAtKey: CreatedAtKey { get }

    /// The date at which this model was last updated.
    /// `nil` if the model has not been created yet.
    static var updatedAtKey: UpdatedAtKey { get }
}

/// Type-erased `Timestampable` protocol. Unfortunately we need this hack until we have existentials.
/// - note: do not rely on this exterally.
public protocol AnyTimestampable: AnyModel {
    /// Type-erased `AnyKeyPath` to the created at key.
    static var fluentCreatedAtKey: AnyKeyPath { get }

    /// Type-erased `AnyKeyPath` to the updated at key.
    static var fluentUpdatedAtKey: AnyKeyPath { get }

    /// Access the created at property.
    var fluentCreatedAt: Date? { get set }

    /// Access the updated at property.
    var fluentUpdatedAt: Date? { get set }
}

extension AnyTimestampable where Self: Timestampable {
    /// See `AnyTimestampable`.
    public static var fluentCreatedAtKey: AnyKeyPath {
        return createdAtKey
    }

    /// See `AnyTimestampable`.
    public static var fluentUpdatedAtKey: AnyKeyPath {
        return updatedAtKey
    }

    /// See `AnyTimestampable`.
    public var fluentCreatedAt: Date? {
        get { return self[keyPath: Self.createdAtKey] }
        set { self[keyPath: Self.createdAtKey] = newValue }
    }

    /// See `AnyTimestampable`.
    public var fluentUpdatedAt: Date? {
        get { return self[keyPath: Self.updatedAtKey] }
        set { self[keyPath: Self.updatedAtKey] = newValue }
    }
}

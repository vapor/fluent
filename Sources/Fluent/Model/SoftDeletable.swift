/// Capable of being "soft deleted". Instead of actually deleting rows from the database,
/// soft deleted models have a "deleted at" property set. All queries made on soft-deletable
/// models will exclude results where the deleted at property is equal to or before the current date.
///
///     final class User: Model {
///         ...
///         var deletedAt: Date?
///     }
///
///     extension User: SoftDeletable {
///         static let deletedAtKey: DeletedAtKey = \.deletedAt
///     }
///
/// You can add `SoftDeletable` to existing models that have an optional `Date` property for storing the
/// deleted at date.
///
/// - note: The deleted at date my be set in the future. The model will continue to be included in
///         queries until the deleted at date passes.
///
/// Use `forceDelete(on:)` to actually delete a soft-deletable model from the database.
/// Use `withSoftDeleted()` on `QueryBuilder` to include soft-deleted results (excluded by default).
public protocol SoftDeletable: Model, AnySoftDeletable {
    /// Swift `KeyPath` referencing deleted at property.
    typealias DeletedAtKey = WritableKeyPath<Self, Date?>

    /// The date at which this model was or will be soft deleted. `nil` if the model has not been deleted yet.
    /// If this property is set, the model will not be included in any query results unless
    /// `withSoftDeleted()` is used on the `QueryBuilder`.
    static var deletedAtKey: DeletedAtKey { get }
}

/// Type-erased `SoftDeletable`. Unfortunately we need this hack until we have existentials.
/// - warning: Do not rely on this exterally.
public protocol AnySoftDeletable: AnyModel {
    /// Type-erased `AnyKeyPath` to the deleted at key.
    static var fluentDeletedAtKey: AnyKeyPath { get }

    /// Access the deleted at property.
    var fluentDeletedAt: Date? { get set }
}

extension AnySoftDeletable where Self: SoftDeletable {
    /// See `AnySoftDeletable`.
    public static var fluentDeletedAtKey: AnyKeyPath {
        return deletedAtKey
    }

    /// See `AnySoftDeletable`.
    public var fluentDeletedAt: Date? {
        get { return self[keyPath: Self.deletedAtKey] }
        set { self[keyPath: Self.deletedAtKey] = newValue }
    }
}

// MARK: Model

extension Model where Self: SoftDeletable, Database: QuerySupporting {
    /// Permanently deletes a soft deletable model.
    ///
    ///     user.forceDelete(on: req)
    ///
    /// - parameters:
    ///     - conn: Used to fetch a database connection.
    /// - returns: A future that will be completed when the force delete finishes.
    public func forceDelete(on conn: DatabaseConnectable) -> Future<Void> {
        return query(on: conn)._delete(self)
    }

    /// Restores a soft deleted model.
    ///
    ///     user.restore(on: req)
    ///
    /// - parameters:
    ///     - conn: Used to fetch a database connection.
    /// - returns: A future that will return the succesfully restored model.
    public func restore(on conn: DatabaseConnectable) -> Future<Self> {
        var copy = self
        copy.fluentDeletedAt = nil
        return query(on: conn).withSoftDeleted().update(copy)
    }
}

/// MARK: Future Model

extension Future where T: SoftDeletable, T.Database: QuerySupporting {
    /// See `SoftDeletable`.
    public func forceDelete(on conn: DatabaseConnectable) -> Future<Void> {
        return flatMap(to: Void.self) { model in
            return model.forceDelete(on: conn)
        }
    }

    /// See `SoftDeletable`.
    public func restore(on conn: DatabaseConnectable) -> Future<T> {
        return flatMap(to: T.self) { model in
            return model.restore(on: conn)
        }
    }
}

// MARK: Query

extension QueryBuilder where Model: SoftDeletable {
    /// Includes soft deleted models in the results.
    ///
    ///     let users = User.query(on: req).withSoftDeleted().all()
    ///
    /// - returns: Self for chaining.
    @discardableResult
    public func withSoftDeleted() -> Self {
        shouldIncludeSoftDeleted = true
        return self
    }
}


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
public protocol SoftDeletable: Model {
    /// Swift `KeyPath` referencing deleted at property.
    typealias DeletedAtKey = WritableKeyPath<Self, Date?>

    /// The date at which this model was or will be soft deleted. `nil` if the model has not been deleted yet.
    /// If this property is set, the model will not be included in any query results unless
    /// `withSoftDeleted()` is used on the `QueryBuilder`.
    static var deletedAtKey: DeletedAtKey { get }
    
    
    /// Called before a model is restored (from being soft deleted).
    /// - note: Throwing will cancel the restore.
    /// - parameters:
    ///     - conn: Current database connection.
    func willRestore(on conn: Database.Connection) throws -> Future<Self>
    /// Called after the model is restored (from being soft deleted.
    /// - parameters:
    ///     - conn: Current database connection.
    func didRestore(on conn: Database.Connection) throws -> Future<Self>
    
    
    /// Called before a model is soft deleted.
    /// - note: Throwing will cancel the soft delete.
    /// - parameters:
    ///     - conn: Current database connection.
    func willSoftDelete(on conn: Database.Connection) throws -> Future<Self>
    /// Called after the model is soft deleted.
    /// - parameters:
    ///     - conn: Current database connection.
    func didSoftDelete(on conn: Database.Connection) throws -> Future<Self>
}

extension SoftDeletable {
    /// See `SoftDeletable`.
    public var fluentDeletedAt: Date? {
        get { return self[keyPath: Self.deletedAtKey] }
        set { self[keyPath: Self.deletedAtKey] = newValue }
    }
    
    /// See `SoftDeletable`.
    public func willRestore(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `SoftDeletable`.
    public func didRestore(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `SoftDeletable`.
    public func willSoftDelete(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `SoftDeletable`.
    public func didSoftDelete(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
}

// MARK: Model

extension Model where Self: SoftDeletable, Database: QuerySupporting {
    /// Temporarily deletes a soft deletable model.
    ///
    ///     user.softDelete(on: req)
    ///
    /// - parameters:
    ///     - conn: Used to fetch a database connection.
    /// - returns: A future that will be completed when the force delete finishes.
    public func softDelete(on conn: DatabaseConnectable) -> Future<Void> {
        return query(on: conn).softDelete(self)
    }

    /// Restores a soft deleted model.
    ///
    ///     user.restore(on: req)
    ///
    /// - parameters:
    ///     - conn: Used to fetch a database connection.
    /// - returns: A future that will return the succesfully restored model.
    public func restore(on conn: DatabaseConnectable) -> Future<Self> {
        let builder = query(on: conn)
        return builder.connection.flatMap { conn in
            return try self.willRestore(on: conn).flatMap { model -> Future<Self> in
                var copy = model
                copy.fluentDeletedAt = nil
                return builder.update(copy)
            }.flatMap { model in
                return try model.didRestore(on: conn)
            }
        }
    }
}

/// MARK: Future Model

extension Future where T: SoftDeletable {
    /// See `SoftDeletable`.
    public func softDelete(on conn: DatabaseConnectable) -> Future<Void> {
        return flatMap(to: Void.self) { model in
            return model.softDelete(on: conn)
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

extension QueryBuilder where Result: SoftDeletable, Result.Database == Database {
    /// Excludes soft-deleted models from the query.
    ///
    ///     User.query(on: req.).excludeSoftDeleted().all()
    ///
    /// - returns: Self for chaining.
    public func excludeSoftDeleted() -> Self {
        /// if the model is soft deletable, and soft deleted
        /// models were not requested, then exclude the
        return group(Database.queryFilterRelationOr) { or in
            or.filter(Result.deletedAtKey == nil)
            or.filter(Result.deletedAtKey > Date())
        }
    }
    
    public func softDelete() -> Future<Void> {
        let field: Database.QueryField = Database.queryField(.keyPath(Result.deletedAtKey))
        Database.queryDataSet(field, to: Date?.none, on: &query)
        return run(Database.queryActionUpdate)
    }
    
    public func softDelete(_ model: Result) -> Future<Void> {
        return connection.flatMap { conn in
            return try model.willSoftDelete(on: conn).flatMap { model -> Future<Result> in
                var copy = model
                copy.fluentDeletedAt = Date()
                return self.update(copy)
            }.flatMap { model in
                return try model.didSoftDelete(on: conn)
            }
        }.transform(to: ())
    }
}


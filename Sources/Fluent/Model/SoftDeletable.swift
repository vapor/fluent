import Core
import Async
import Foundation

/// Has create and update timestamps.
public protocol SoftDeletable: Model, AnySoftDeletable {
    /// Key referencing deleted at property.
    typealias DeletedAtKey = WritableKeyPath<Self, Date?>

    /// The date at which this model was deleted.
    /// nil if the model has not been deleted yet.
    /// If this property is true, the model will not
    /// be included in any query results unless
    /// `.withSoftDeleted()` is used.
    static var deletedAtKey: DeletedAtKey { get }
}

extension SoftDeletable {
    /// Fluent deleted at property.
    public var fluentDeletedAt: Date? {
        get { return self[keyPath: Self.deletedAtKey] }
        set { self[keyPath: Self.deletedAtKey] = newValue }
    }
}

// MARK: Model

extension Model where Self: SoftDeletable, Database: QuerySupporting {
    /// Permanently deletes a soft deletable model.
    public func forceDelete(on conn: DatabaseConnectable) -> Future<Void> {
        return query(on: conn)._delete(self)
    }

    /// Restores a soft deleted model.
    public func restore(on conn: DatabaseConnectable) -> Future<Self> {
        var copy = self
        copy.fluentDeletedAt = nil
        return query(on: conn).withSoftDeleted().update(copy)
    }
}

/// MARK: Future Model

extension Future where T: SoftDeletable, T.Database: QuerySupporting {
    /// See `Model.forceDelete(on:)`
    public func forceDelete(on conn: DatabaseConnectable) -> Future<Void> {
        return flatMap(to: Void.self) { model in
            return model.forceDelete(on: conn)
        }
    }

    /// See `Model.restore(on:)`
    public func restore(on conn: DatabaseConnectable) -> Future<T> {
        return flatMap(to: T.self) { model in
            return model.restore(on: conn)
        }
    }
}

// MARK: Query

extension DatabaseQuery {
    /// If true, soft deleted models should be included.
    internal var withSoftDeleted: Bool {
        get { return extend["withSoftDeleted"] as? Bool ?? false }
        set { extend["withSoftDeleted"] = newValue }
    }
}

extension QueryBuilder where Model: SoftDeletable {
    /// Includes soft deleted models in the results.
    public func withSoftDeleted() -> Self {
        query.withSoftDeleted = true
        return self
    }
}

/// Unfortunately we need this hack until we have existentials.
/// note: do not rely on this exterally.
public protocol AnySoftDeletable: AnyModel {
    /// Pointer to type erased key string
    static func deletedAtField() throws -> QueryField

    /// Access the deleted at property.
    var fluentDeletedAt: Date? { get set }
}

extension SoftDeletable {
    /// See `AnySoftDeletable.deletedAtField`
    public static func deletedAtField() throws -> QueryField {
        guard let name = try Self.reflectProperty(forKey: deletedAtKey) else {
            throw FluentError(identifier: "reflectProperty", reason: "No property reflected for \(deletedAtKey)", source: .capture())
        }
        return QueryField(
            entity: entity,
            name: name.path.first ?? ""
        )
    }
}

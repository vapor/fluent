import Foundation

/// Has create and update timestamps.
public protocol Timestampable: AnyTimestampable {
    /// Key referencing created at property.
    typealias CreatedAtKey = WritableKeyPath<Self, Date?>

    /// Key referencing updated at property.
    typealias UpdatedAtKey = WritableKeyPath<Self, Date?>

    /// The date at which this model was created.
    /// nil if the model has not been created yet.
    static var createdAtKey: CreatedAtKey { get }

    /// The date at which this model was last updated.
    /// nil if the model has not been created yet.
    static var updatedAtKey: UpdatedAtKey { get }
}

extension Timestampable {
    /// Fluent deleted at property.
    public var fluentCreatedAt: Date? {
        get { return self[keyPath: Self.createdAtKey] }
        set { self[keyPath: Self.createdAtKey] = newValue }
    }

    /// Fluent deleted at property.
    public var fluentUpdatedAt: Date? {
        get { return self[keyPath: Self.updatedAtKey] }
        set { self[keyPath: Self.updatedAtKey] = newValue }
    }
}

/// Unfortunately we need this hack until we have existentials.
/// note: do not rely on this exterally.
public protocol AnyTimestampable: AnyModel {
    /// Access the created at property.
    var fluentCreatedAt: Date? { get set }

    /// Access the updated at property.
    var fluentUpdatedAt: Date? { get set }
}

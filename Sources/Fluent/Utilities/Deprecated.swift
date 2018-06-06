/// - warning: Deprecated.
@available(*, deprecated, renamed: "CacheEntry")
public typealias FluentCacheEntry = CacheEntry

extension Model {
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "TimestampKey")
    public typealias CreatedAtKey = TimestampKey
    
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "TimestampKey")
    public typealias UpdatedAtKey = TimestampKey
    
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "TimestampKey")
    public typealias DeletedAtKey = TimestampKey
    
    /// - warning: Deprecated.
    @available(*, deprecated, message: "This method is redundant and will be removed. Use static method on Model instead: User.query(on:)")
    public func query(on conn: DatabaseConnectable) -> QueryBuilder<Self.Database, Self> {
        return Self.query(on: conn)
    }
}

extension QueryBuilder {
    /// - warning: Deprecated.
    @available(*, deprecated, message: "Use Model.query(on:withSoftDeleted:)")
    public func withSoftDeleted() -> QueryBuilder<Database, Result> {
        fatalError("Use Model.query(on:withSoftDeleted:)")
    }
}

extension Model {
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "delete(force:on:)")
    public func forceDelete(on conn: Database.Connection) -> Future<Void> {
        return delete(force: true, on: conn)
    }
}

/// - warning: Deprecated.
@available(*, deprecated, message: "Model now supports timestamps via an _optional_ static key.")
public protocol Timestampable { }

/// - warning: Deprecated.
@available(*, deprecated, message: "Model now supports soft-deletion via an _optional_ static key.")
public protocol SoftDeletable { }

extension DatabaseConnectable {
    /// - warning: Deprecated.
    @available(*, deprecated, message: "This method is redundant and will be removed. Use static method on Model instead: User.query(on:)")
    public func query<Model>(_ model: Model.Type) -> QueryBuilder<Model.Database, Model> where Model: Fluent.Model {
        return Model.query(on: self)
    }
}


extension SchemaBuilder {
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "reference(from:to:)")
    public func addReference<T, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, T>)
        where Other: Fluent.Model
    {
        reference(from: base, to: referenced)
    }
    
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "reference(from:to:)")
    public func addReference<T, Other>(from base: KeyPath<Model, T?>, to referenced: KeyPath<Other, T>)
        where Other: Fluent.Model
    {
        reference(from: base, to: referenced)
    }
    
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "reference(from:to:)")
    public func addReference<T, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, T?>)
        where Other: Fluent.Model
    {
        reference(from: base, to: referenced)
    }
}


extension SchemaBuilder {
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "unique(on:)")
    public func addIndex<T>(to: KeyPath<Model, T>, isUnique: Bool = false) {
        return unique(on: to)
    }
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "unique(on:_:)")
    public func addIndex<A, B>(to: KeyPath<Model, A>, _ and: KeyPath<Model, B>, isUnique: Bool = false) {
        return unique(on: to, and)
    }
}

extension SchemaUpdater {
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "deleteField(for:)")
    public func removeField<T>(for field: KeyPath<Model, T>) {
        self.deleteField(for: field)
    }
    
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "deleteField(_:)")
    public func removeField(_ column: Model.Database.QueryField) {
        self.deleteField(column)
    }
}

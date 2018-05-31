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
    @available(*, deprecated, message: "This method is redundant and will be removed. Use static method on Model instead: User.query(on:)")
    public func query(on conn: DatabaseConnectable) -> QueryBuilder<Self.Database, Self> {
        return Self.query(on: conn)
    }
    
}

/// - warning: Deprecated.
@available(*, deprecated, renamed: "Model")
public protocol Timestampable { }

extension DatabaseConnectable {
    /// - warning: Deprecated.
    @available(*, deprecated, message: "This method is redundant and will be removed. Use static method on Model instead: User.query(on:)")
    public func query<Model>(_ model: Model.Type) -> QueryBuilder<Model.Database, Model> where Model: Fluent.Model {
        return Model.query(on: self)
    }
}

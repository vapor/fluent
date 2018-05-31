extension SchemaBuilder {
    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "foreignKey(from:to:)")
    public func addReference<T, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, T>)
        where Other: Fluent.Model
    {
        foreignKey(from: base, to: referenced)
    }

    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "foreignKey(from:to:)")
    public func addReference<T, Other>(from base: KeyPath<Model, T?>, to referenced: KeyPath<Other, T>)
        where Other: Fluent.Model
    {
        foreignKey(from: base, to: referenced)
    }

    /// - warning: Deprecated.
    @available(*, deprecated, renamed: "foreignKey(from:to:)")
    public func addReference<T, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, T?>)
        where Other: Fluent.Model
    {
        foreignKey(from: base, to: referenced)
    }
}

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

@available(*, deprecated, renamed: "Model")
public protocol Timestampable { }

extension DatabaseConnectable {
    /// - warning: Deprecated.
    @available(*, deprecated, message: "This method is redundant and will be removed. Use static method on Model instead: User.query(on:)")
    public func query<Model>(_ model: Model.Type) -> QueryBuilder<Model.Database, Model> where Model: Fluent.Model {
        return Model.query(on: self)
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

@available(*, deprecated, renamed: "SQLDatabase")
public typealias SchemaSupporting = SQLSupporting

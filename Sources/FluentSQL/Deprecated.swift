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

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

@available(*, deprecated, renamed: "SQLDatabase")
public typealias SchemaSupporting = SQLDatabase

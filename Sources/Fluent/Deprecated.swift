
extension QueryBuilder {
    /// Subset `in` filter.
    @available(*, deprecated, message: "Use ~~ operator.")
    @discardableResult
    public func filter<T>(_ field: KeyPath<Model, T>, in values: [Model.Database.QueryDataConvertible]) throws -> Self {
        return try filter(field, .in, .array(values))
    }

    /// Subset `notIn` filter.
    @available(*, deprecated, message: "Use !~ operator.")
    @discardableResult
    public func filter<T>(_ field: KeyPath<Model, T>, notIn values: [T]) throws -> Self {
        return try filter(field, .notIn, .array(values))
    }
}

extension QueryBuilder {
    /// Subset `in` filter.
    @available(*, deprecated, message: "Use ~~ operator.")
    @discardableResult
    public func filter<M, T>(_ joined: M.Type, _ field: KeyPath<M, T>, in values: [Model.Database.QueryDataConvertible]) throws -> Self
        where M: Fluent.Model, M.Database == Model.Database
    {
        return try filter(M.self, field, .in, .array(values))
    }

    /// Subset `notIn` filter.
    @available(*, deprecated, message: "Use !~ operator.")
    @discardableResult
    public func filter<M, T>(_ joined: M.Type, _ field: KeyPath<M, T>, notIn values: [Model.Database.QueryDataConvertible]) throws -> Self
        where M: Fluent.Model, M.Database == Model.Database
    {
        return try filter(M.self, field, .notIn, .array(values))
    }
}

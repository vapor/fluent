extension QueryBuilder {
    // MARK: Filter

    /// Applies a filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter(\.name, .equals, "Vapor")
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter<T>(_ key: KeyPath<Model, T>, _ method: Model.Database.Query.Filter.Method, _ value: T) -> Self
        where T: Encodable
    {
        if value.isNil {
            return filter(.keyPath(key), method, .fluentNil)
        } else {
            query.fluentBinds.append(.fluentEncodable(value))
            return filter(.keyPath(key), method, .fluentBind(1))
        }
    }

    /// Applies a filter to this query for a joined entity. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(Pet.self, ...)
    ///         .filter(\Pet.type, .equals, .cat)
    ///         .all()
    ///
    /// - parameters:
    ///     - joined: Joined model type to filter.
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter<A, T>(_ key: KeyPath<A, T>, _ method: Model.Database.Query.Filter.Method, _ value: Encodable) -> Self
        where A: Fluent.Model, A.Database == Model.Database
    {
        if value.isNil {
            return filter(.keyPath(key), method, .fluentNil)
        } else {
            query.fluentBinds.append(.fluentEncodable(value))
            return filter(.keyPath(key), method, value)
        }
    }

    /// Applies a filter to this query using a custom field. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter("name", .equals, "Vapor")
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter(_ field: Model.Database.Query.Filter.Field, _ method: Model.Database.Query.Filter.Method, _ value: Encodable) -> Self {
        if value.isNil {
            return filter(field, method, .fluentNil)
        } else {
            query.fluentBinds.append(.fluentEncodable(value))
            return filter(field, method, .fluentBind(1))
        }
    }

    /// Applies a filter to this query using a custom field. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter("name", .equals, "Vapor")
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    private func filter(_ field: Model.Database.Query.Filter.Field, _ method: Model.Database.Query.Filter.Method, _ value: Model.Database.Query.Filter.Value) -> Self {
        return filter(.fluentFilter(field, method, value))
    }

    /// Add a manually created filter to the query builder.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter(_ filter: Model.Database.Query.Filter) -> Self {
        query.fluentFilters.append(filter)
        return self
    }

    // MARK: Filter Group

    /// Creates a sub group for this query. This is useful for grouping multiple filters by `.or` instead of `.and`.
    ///
    ///     let users = try User.query(on: conn).group(.or) { or in
    ///         or.filter(\.age < 18)
    ///         or.filter(\.age > 65)
    ///     }
    ///
    /// - parameters:
    ///     - relation: `.and` or `.or` relation for the filters added in the closure.
    ///     - closure: A sub-query builder to use for adding grouped filters.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func group(_ relation: Model.Database.Query.Filter.Relation, closure: @escaping (QueryBuilder<Model, Result>) throws -> ()) rethrows -> Self {
        // FIXME: more efficient copy?
        let sub = copy()
        // clear the subquery
        sub.query.fluentFilters.removeAll()
        sub.query.fluentBinds.removeAll()
        // run
        try closure(sub)
        // copy binds + filter
        self.query.fluentBinds += sub.query.fluentBinds
        self.query.fluentFilters += [.fluentFilterGroup(relation, sub.query.fluentFilters)]
        return self
    }
}

internal extension Encodable {
    /// Returns `true` if this `Encodable` is `nil`.
    var isNil: Bool {
        guard let optional = self as? AnyOptionalType, optional.anyWrapped == nil else {
            return false
        }
        return true
    }
}

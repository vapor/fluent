extension QueryBuilder {
    // MARK: Filter

    /// Applies a filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter(\.name, .equal, "Vapor")
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter<T>(_ key: KeyPath<Result, T>, _ method: Database.QueryFilterMethod, _ value: T) -> Self
        where T: Encodable
    {
        if value.isNil {
            return filter(Database.queryField(.keyPath(key)), method, Database.queryFilterValueNil)
        } else {
            return filter(Database.queryField(.keyPath(key)), method, Database.queryFilterValue([value]))
        }
    }

    /// Applies a filter to this query for a joined entity. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(Pet.self, ...)
    ///         .filter(\Pet.type, .equal, .cat)
    ///         .all()
    ///
    /// - parameters:
    ///     - joined: Joined model type to filter.
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter<A, T>(_ key: KeyPath<A, T>, _ method: Database.QueryFilterMethod, _ value: T) -> Self
        where T: Encodable
    {
        if value.isNil {
            return filter(Database.queryField(.keyPath(key)), method, Database.queryFilterValueNil)
        } else {
            return filter(Database.queryField(.keyPath(key)), method, Database.queryFilterValue([value]))
        }
    }

    /// Applies a filter to this query using a custom field. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter("name", .equal, "Vapor")
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter<T>(_ field: Database.QueryField, _ method: Database.QueryFilterMethod, _ value: T) -> Self
        where T: Encodable
    {
        if value.isNil {
            return filter(field, method, Database.queryFilterValueNil)
        } else {
            return filter(field, method, Database.queryFilterValue([value]))
        }
    }

    /// Applies a filter to this query using a custom field. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter("name", .equal, "Vapor")
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    private func filter(_ field: Database.QueryField, _ method: Database.QueryFilterMethod, _ value: Database.QueryFilterValue) -> Self {
        return filter(Database.queryFilter(field, method, value))
    }

    /// Add a manually created filter to the query builder.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter(_ filter: Database.QueryFilter) -> Self {
        Database.queryFilterApply(filter, to: &query)
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
    public func group(_ relation: Database.QueryFilterRelation, closure: @escaping (QueryBuilder<Database, Result>) throws -> ()) rethrows -> Self {
        // switch this query builder to an empty query, saving the main query
        let main = query
        query = Database.query(Database.queryEntity(for: query))
        Database.queryDefaultFilterRelation(relation, on: &query)

        // run
        try closure(self)

        // switch back to the query, saving the subquery
        let sub = query
        query = main

        // apply the sub-filters as a group
        Database.queryFilterApply(Database.queryFilterGroup(relation, Database.queryFilters(for: sub)), to: &query)
        return self
    }
}

// MARK: Internal

internal extension Encodable {
    /// Returns `true` if this `Encodable` is `nil`.
    var isNil: Bool {
        guard let optional = self as? AnyOptionalType, optional.anyWrapped == nil else {
            return false
        }
        return true
    }
}

extension Query {
    // MARK: Filter

    /// Single `FilterItem` or a group of `FilterItems`.
    public enum Filter {
        /// Defines a filter that can be added on fetch, delete, and update operations to limit the set of data affected.
        public struct Unit {
            /// The field to filter.
            public var field: Field

            /// The filter type.
            public var method: Method

            /// The filter value, possibly another field.
            public var value: Value

            /// Create a new `FilterItem`.
            ///
            /// - parameters:
            ///     - field: Query field to filter.
            ///     - type: Filter type.
            ///     - value: Value for the filter type.
            public init(field: Field, method: Method, value: Value) {
                self.field = field
                self.method = method
                self.value = value
            }
        }

        /// Possible relations between items in a group
        public enum Relation {
            /// All filters must be satisfied for the group to be satisfied.
            case and
            /// At least one of the filters must be satisfied for the group to be satisfied.
            case or
        }


        /// Supported filter types.
        public enum Method {
            case equal
            case notEqual
            case greaterThan
            case lessThan
            case greaterThanOrEqual
            case lessThanOrEqual
            case `in`
            case notIn
            case custom(Database.FilterMethodType)
        }

        /// A single `FilterItem` containing type and value.
        case single(Unit)

        /// A nested group of `Filter`s, possibly containing more nested groups.
        /// These filters are joined by the specified `GroupRelation`.
        case group(Relation, [Filter])
    }
}

extension Query.Builder {
    // MARK: Filter

    /// Applies a filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter(\.name, .equals, .data("Vapor"))
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter<T>(_ key: KeyPath<Model, T>, _ method: Query.Filter.Method, _ value: Query.Value) -> Self {
        return filter(.keyPath(key), method, value)
    }

    /// Applies a filter to this query for a joined entity. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(Pet.self, ...)
    ///         .filter(Pet.self, \.type, .equals, .data("cat"))
    ///         .all()
    ///
    /// - parameters:
    ///     - joined: Joined model type to filter.
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter<A, T>(_ key: KeyPath<A, T>, _ method: Query.Filter.Method, _ value: Query.Value) -> Self
        where A: Fluent.Model, A.Database == Model.Database
    {
        return addFilter(.single(.init(field: .keyPath(key), method: method, value: value)))
    }

    /// Applies a filter to this query using a custom field. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filter("name", .equals, .data("Vapor"))
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter(_ field: Query.Field, _ method: Query.Filter.Method, _ value: Query.Value) -> Self {
        return addFilter(.single(.init(field: field, method: method, value: value)))
    }

    /// Add a manually created filter to the query builder.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func addFilter(_ filter: Query.Filter) -> Self {
        query.filters.append(filter)
        return self
    }

    // MARK: Filter Group

    /// Creates a sub group for this query. This is useful for grouping multiple filters by `.or` instead of `.and`.
    ///
    ///     let users = try User.query(on: conn).filter(.or) { or in
    ///         or.filter(\.age < 18)
    ///         or.filter(\.age > 65)
    ///     }
    ///
    /// - parameters:
    ///     - relation: `.and` or `.or` relation for the filters added in the closure.
    ///     - closure: A sub-query builder to use for adding grouped filters.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func group(_ relation: Query.Filter.Relation, closure: @escaping (Query.Builder<Model, Result>) throws -> ()) rethrows -> Self {
        let sub = copy()
        sub.query.filters.removeAll()
        try closure(sub)
        return addFilter(.group(relation, sub.query.filters))
    }
}

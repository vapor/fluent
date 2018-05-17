//extension Query {
//    // MARK: Filter
//
//    /// Single `FilterItem` or a group of `FilterItems`.
//    public enum Filter {
//        /// Defines a filter that can be added on fetch, delete, and update operations to limit the set of data affected.
//        public struct Unit {
//            /// The field to filter.
//            public var field: Database.FieldType
//
//            /// The filter type.
//            public var method: Database.FilterMethodType
//
//            /// The filter value, possibly another field.
//            public var value: Database.FilterValueType
//
//            /// Create a new `FilterItem`.
//            ///
//            /// - parameters:
//            ///     - field: Query field to filter.
//            ///     - type: Filter type.
//            ///     - value: Value for the filter type.
//            public init(field: Database.FieldType, method: Method, value: Database.FilterValueType) {
//                self.field = field
//                self.method = method
//                self.value = value
//            }
//        }
//
//        /// Possible relations between items in a group
//        public enum Relation {
//            /// All filters must be satisfied for the group to be satisfied.
//            case and
//            /// At least one of the filters must be satisfied for the group to be satisfied.
//            case or
//        }
//
//        /// A single `FilterItem` containing type and value.
//        case single(Unit)
//
//        /// A nested group of `Filter`s, possibly containing more nested groups.
//        /// These filters are joined by the specified `GroupRelation`.
//        case group(Relation, [Filter])
//    }
//}

extension QueryBuilder {
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
    ///         .filter("name", .equals, .data("Vapor"))
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filter(_ field: Model.Database.Query.Field, _ method: Model.Database.Query.Filter.Method, _ value: Encodable) -> Self {
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
    ///         .filter("name", .equals, .data("Vapor"))
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - type: Query filter type to use.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    private func filter(_ field: Model.Database.Query.Field, _ method: Model.Database.Query.Filter.Method, _ value: Model.Database.Query.Filter.Value) -> Self {
        return addFilter(.unit(field, method, value))
    }

    /// Add a manually created filter to the query builder.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func addFilter(_ filter: Model.Database.Query.Filter) -> Self {
        query.fluentFilters.append(filter)
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
        self.query.fluentFilters += [.group(relation, sub.query.fluentFilters)]
        return self
    }
}

extension Encodable {
    var isNil: Bool {
        guard let optional = self as? AnyOptionalType, optional.anyWrapped == nil else {
            return false
        }
        return true
    }
}

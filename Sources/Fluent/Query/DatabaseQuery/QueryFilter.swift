extension DatabaseQuery {
    /// Single `FilterItem` or a group of `FilterItems`.
    public enum Filter {
        /// Possible relations between items in a group
        public enum GroupRelation {
            /// All filters must be satisfied for the group to be satisfied.
            case and
            /// At least one of the filters must be satisfied for the group to be satisfied.
            case or
        }

        /// A single `FilterItem` containing type and value.
        case single(FilterItem)

        /// A nested group of `Filter`s, possibly containing more nested groups.
        /// These filters are joined by the specified `GroupRelation`.
        case group(GroupRelation, [Filter])
    }

    /// Defines a filter that can be added on fetch, delete, and update operations to limit the set of data affected.
    public struct FilterItem {
        /// The field to filter.
        public var field: Database.QueryField

        /// The filter type.
        public var type: FilterType

        /// The filter value, possibly another field.
        public var value: FilterValue

        /// Create a new `FilterItem`.
        ///
        /// - parameters:
        ///     - field: Query field to filter.
        ///     - type: Filter type.
        ///     - value: Value for the filter type.
        public init(field: Database.QueryField, type: FilterType, value: FilterValue) {
            self.field = field
            self.type = type
            self.value = value
        }
    }

    /// Supported filter types.
    public struct FilterType: Equatable {
        /// Internal storage type.
        internal enum Storage: Equatable {
            case equals
            case notEquals
            case greaterThan
            case lessThan
            case greaterThanOrEquals
            case lessThanOrEquals
            case `in`
            case notIn
            case custom(Database.QueryFilter)
        }

        /// Internal storage.
        internal let storage: Storage

        /// Returns the custom query filter if it is set.
        public func custom() -> Database.QueryFilter? {
            switch storage {
            case .custom(let filter): return filter
            default: return nil
            }
        }

        /// ==
        public static var equals: FilterType { return .init(storage: .equals) }
        /// !=
        public static var notEquals: FilterType { return .init(storage: .notEquals) }
        /// >
        public static var greaterThan: FilterType { return .init(storage: .greaterThan) }
        /// <
        public static var lessThan: FilterType { return .init(storage: .lessThan) }
        /// >=
        public static var greaterThanOrEquals: FilterType { return .init(storage: .greaterThanOrEquals) }
        /// <=
        public static var lessThanOrEquals: FilterType { return .init(storage: .lessThanOrEquals) }
        /// part of
        public static var `in`: FilterType { return .init(storage: .`in`) }
        /// not a part of
        public static var notIn: FilterType { return .init(storage: .notIn) }

        /// Custom filter for this database type.
        public static func custom(_ filter: Database.QueryFilter) -> FilterType {
            return .init(storage: .custom(filter))
        }
    }

    /// Supported filter values.
    public struct FilterValue {
        enum QueryFilterValueStorage {
            case field(Database.QueryField)
            case data(Database.QueryData)
            case array([Database.QueryData])
            case subquery(DatabaseQuery<Database>)
            case none
        }

        /// Internal storage.
        let storage: QueryFilterValueStorage

        /// Returns the `QueryField` value if it exists.
        public func field() -> Database.QueryField? {
            switch storage {
            case .field(let field): return field
            default: return nil
            }
        }

        /// Returns the values as an array of query data, if possible.
        public func data() -> [Database.QueryData]? {
            switch storage {
            case .data(let data): return [data]
            case .array(let a): return a
            default: return nil
            }
        }

        /// Another query field.
        public static func field(_ field: Database.QueryField) -> FilterValue {
            return .init(storage: .field(field))
        }

        /// A single value.
        public static func custom(_ data: Database.QueryData) -> FilterValue {
            return .init(storage: .data(data))
        }

        /// A single value.
        public static func data<T>(_ data: T) throws -> FilterValue {
            return try .custom(Database.queryDataEncode(data))
        }

        /// An array of values.
        public static func array<T>(_ array: [T]) throws -> FilterValue {
            let array = try array.map { try Database.queryDataEncode($0) }
            return .init(storage: .array(array))
        }

        /// A sub query.
        public static func subquery(_ subquery: DatabaseQuery<Database>) -> FilterValue {
            return .init(storage: .subquery(subquery))
        }

        /// No value.
        public static func none() -> FilterValue {
            return .init(storage: .none)
        }
    }
}

extension QueryBuilder {
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
    public func filter<M, T>(_ joined: M.Type, _ key: KeyPath<M, T>, _ type: DatabaseQuery<M.Database>.FilterType, _ value: DatabaseQuery<M.Database>.FilterValue) throws -> Self
        where M: Fluent.Model, M.Database == Model.Database
    {
        let filter = try DatabaseQuery<M.Database>.FilterItem(field: M.Database.queryField(for: key), type: type, value: value)
        return addFilter(.single(filter))
    }

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
    public func filter<T>(_ key: KeyPath<Model, T>, _ type: DatabaseQuery<Model.Database>.FilterType, _ value: DatabaseQuery<Model.Database>.FilterValue) throws -> Self {
        return try filter(Model.Database.queryField(for: key), type, value)
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
    public func filter(_ field: Model.Database.QueryField, _ type: DatabaseQuery<Model.Database>.FilterType, _ value: DatabaseQuery<Model.Database>.FilterValue) -> Self {
        let filter = DatabaseQuery<Model.Database>.FilterItem(field: field, type: type, value: value)
        return addFilter(.single(filter))
    }
}

/// MARK: Group

extension QueryBuilder {
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
    public func group(_ relation: DatabaseQuery<Model.Database>.Filter.GroupRelation, closure: @escaping (QueryBuilder<Model, Result>) throws -> ()) rethrows -> Self {
        let sub = copy()
        sub.query.filters.removeAll()
        try closure(sub)
        return addFilter(.group(relation, sub.query.filters))
    }
}

extension QueryBuilder {
    /// Add a manually created filter to the query builder.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func addFilter(_ filter: DatabaseQuery<Model.Database>.Filter) -> Self {
        query.filters.append(filter)
        return self
    }
}

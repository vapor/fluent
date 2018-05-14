extension DatabaseQuery {
    /// Single `FilterItem` or a group of `FilterItems`.
    public enum Filter {
        /// Possible relations between items in a group
        public enum GroupRelation {
            case and, or
        }

        /// A single `FilterItem` containing type and value.
        case single(FilterItem)

        /// A nested group of `Filter`s, possibly containing more nested groups.
        /// These filters are joined by the specified `GroupRelation`.
        case group(GroupRelation, [Filter])
    }

    /// Defines a `Filter` that can be added on fetch, delete, and update operations to limit the set of data affected.
    public struct FilterItem {
        /// The field to filer.
        public var field: QueryField

        /// The filter type.
        public var type: FilterType

        /// The filter value, possible another field.
        public var value: FilterValue

        /// Create a new filter.
        public init(field: QueryField, type: FilterType, value: FilterValue) {
            self.field = field
            self.type = type
            self.value = value
        }
    }

    /// Supported filter comparison types.
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

    /// Describes the values a subset can have. The subset can be either an array of encodable
    /// values or another query whose purpose is to yield an array of values.
    public struct FilterValue {
        enum QueryFilterValueStorage {
            case field(QueryField)
            case data(Database.QueryData)
            case array([Database.QueryData])
            case subquery(DatabaseQuery<Database>)
            case none
        }

        /// Internal storage.
        let storage: QueryFilterValueStorage

        /// Returns the `QueryField` value if it exists.
        public func field() -> QueryField? {
            switch storage {
            case .field(let field): return field
            default: return nil
            }
        }

        /// Returns the `Database.QueryData` value if it exists.
        public func data() -> [Database.QueryData]? {
            switch storage {
            case .data(let data): return [data]
            case .array(let a): return a
            default: return nil
            }
        }

        /// Another query field.
        public static func field(_ field: QueryField) -> FilterValue {
            return .init(storage: .field(field))
        }

        /// A single value.
        public static func data<T>(_ data: T) throws -> FilterValue {
            return try .init(storage: .data(Database.queryDataSerialize(data: data)))
        }

        /// A single value.
        public static func array<T>(_ array: [T]) throws -> FilterValue {
            let array = try array.map { try Database.queryDataSerialize(data: $0) }
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
    /// Applies a comparison filter to this query.
    @discardableResult
    public func filter<M, T>(_ joined: M.Type, _ key: KeyPath<M, T>, _ type: DatabaseQuery<M.Database>.FilterType, _ value: DatabaseQuery<M.Database>.FilterValue) throws -> Self
        where M: Fluent.Model, M.Database == Model.Database
    {
        let filter = try DatabaseQuery<M.Database>.FilterItem(field: key.makeQueryField(), type: type, value: value)
        return addFilter(.single(filter))
    }

    /// Applies a comparison filter to this query.
    @discardableResult
    public func filter<T>(_ key: KeyPath<Model, T>, _ type: DatabaseQuery<Model.Database>.FilterType, _ value: DatabaseQuery<Model.Database>.FilterValue) throws -> Self {
        return try filter(key.makeQueryField(), type, value)
    }

    /// Applies a comparison filter to this query.
    @discardableResult
    public func filter(_ field: QueryField, _ type: DatabaseQuery<Model.Database>.FilterType, _ value: DatabaseQuery<Model.Database>.FilterValue) -> Self {
        let filter = DatabaseQuery<Model.Database>.FilterItem(field: field, type: type, value: value)
        return addFilter(.single(filter))
    }
}

/// MARK: Group

extension QueryBuilder {
    /// Create a query group.
    @discardableResult
    public func group(_ relation: DatabaseQuery<Model.Database>.Filter.GroupRelation, closure: @escaping (QueryBuilder<Model, Result>) throws -> ()) rethrows -> Self {
        let sub = copy()
        sub.query.filters.removeAll()
        try closure(sub)
        return addFilter(.group(relation, sub.query.filters))
    }
}

extension QueryBuilder {
    /// Manually create and append filter
    @discardableResult
    public func addFilter(_ filter: DatabaseQuery<Model.Database>.Filter) -> Self {
        query.filters.append(filter)
        return self
    }
}

/// Defines a `Filter` that can be added on fetch, delete, and update operations to limit the set of data affected.
public struct QueryFilter<Database> where Database: QuerySupporting {
    /// The field to filer.
    public var field: QueryField

    /// The filter type.
    public var type: QueryFilterType<Database>

    /// The filter value, possible another field.
    public var value: QueryFilterValue<Database>

    /// Create a new filter.
    public init(field: QueryField, type: QueryFilterType<Database>, value: QueryFilterValue<Database>) {
        self.field = field
        self.type = type
        self.value = value
    }
}

/// Supported filter comparison types.
public struct QueryFilterType<Database>: Equatable where Database: QuerySupporting {
    enum QueryFilterTypeStorage: Equatable {
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
    let storage: QueryFilterTypeStorage

    /// Returns the custom query filter if it is set.
    public func custom() -> Database.QueryFilter? {
        switch storage {
        case .custom(let filter): return filter
        default: return nil
        }
    }

    /// ==
    public static var equals: QueryFilterType<Database> { return .init(storage: .equals) }
    /// !=
    public static var notEquals: QueryFilterType<Database> { return .init(storage: .notEquals) }
    /// >
    public static var greaterThan: QueryFilterType<Database> { return .init(storage: .greaterThan) }
    /// <
    public static var lessThan: QueryFilterType<Database> { return .init(storage: .lessThan) }
    /// >=
    public static var greaterThanOrEquals: QueryFilterType<Database> { return .init(storage: .greaterThanOrEquals) }
    /// <=
    public static var lessThanOrEquals: QueryFilterType<Database> { return .init(storage: .lessThanOrEquals) }
    /// part of
    public static var `in`: QueryFilterType<Database> { return .init(storage: .`in`) }
    /// not a part of
    public static var notIn: QueryFilterType<Database> { return .init(storage: .notIn) }

    /// Custom filter for this database type.
    public static func custom(_ filter: Database.QueryFilter) -> QueryFilterType<Database> {
        return .init(storage: .custom(filter))
    }
}

/// Describes the values a subset can have. The subset can be either an array of encodable
/// values or another query whose purpose is to yield an array of values.
public struct QueryFilterValue<Database> where Database: QuerySupporting {
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
    public static func field(_ field: QueryField) -> QueryFilterValue<Database> {
        return .init(storage: .field(field))
    }

    /// A single value.
    public static func data<T>(_ data: T) throws -> QueryFilterValue<Database> {
        return try .init(storage: .data(Database.queryDataSerialize(data: data)))
    }

    /// A single value.
    public static func array<T>(_ array: [T]) throws -> QueryFilterValue<Database> {
        let array = try array.map { try Database.queryDataSerialize(data: $0) }
        return .init(storage: .array(array))
    }

    /// A sub query.
    public static func subquery(_ subquery: DatabaseQuery<Database>) -> QueryFilterValue<Database> {
        return .init(storage: .subquery(subquery))
    }

    /// No value.
    public static func none() -> QueryFilterValue<Database> {
        return .init(storage: .none)
    }
}

extension QueryBuilder {
    /// Manually create and append filter
    @discardableResult
    public func addFilter(_ filter: QueryFilterItem<Model.Database>) -> Self {
        query.filters.append(filter)
        return self
    }
}

extension QueryBuilder {
    /// Applies a comparison filter to this query.
    @discardableResult
    public func filter<M, T>(_ joined: M.Type, _ key: KeyPath<M, T>, _ type: QueryFilterType<M.Database>, _ value: QueryFilterValue<M.Database>) throws -> Self
        where M: Fluent.Model, M.Database == Model.Database
    {
        let filter = try QueryFilter<M.Database>(
            field: key.makeQueryField(),
            type: type,
            value: value
        )
        return addFilter(.single(filter))
    }

    /// Applies a comparison filter to this query.
    @discardableResult
    public func filter<T>(_ key: KeyPath<Model, T>, _ type: QueryFilterType<Model.Database>, _ value: QueryFilterValue<Model.Database>) throws -> Self {
        return try filter(key.makeQueryField(), type, value)
    }



    /// Applies a comparison filter to this query.
    @discardableResult
    public func filter(_ field: QueryField, _ type: QueryFilterType<Model.Database>, _ value: QueryFilterValue<Model.Database>) -> Self {
        let filter = QueryFilter<Model.Database>(
            field: field,
            type: type,
            value: value
        )
        return addFilter(.single(filter))
    }
}

/// MARK: Group

/// Possible relations between items in a group
public enum QueryGroupRelation {
    case and, or
}

public enum QueryFilterItem<Database> where Database: QuerySupporting {
    case single(QueryFilter<Database>)
    case group(QueryGroupRelation, [QueryFilterItem<Database>])
}

extension QueryBuilder {
    public typealias GroupClosure = (QueryBuilder<Model, Result>) throws -> ()

    /// Create a query group.
    @discardableResult
    public func group(_ relation: QueryGroupRelation, closure: @escaping GroupClosure) rethrows -> Self {
        let sub = copy()
        try closure(sub)
        return addFilter(.group(relation, sub.query.filters))
    }
}


import CodableKit

/// Describes the methods for comparing
/// a field to a set of values.
/// Think of it like Swift's `.contains`.
public enum QuerySubsetScope {
    case `in`
    case notIn
}

/// Describes the values a subset can have. The subset can be either an array of encodable
/// values or another query whose purpose is to yield an array of values.
public enum QuerySubsetValue<Database> where Database: QuerySupporting {
    case array([Database.QueryData])
    case subquery(DatabaseQuery<Database>)
}

extension QueryBuilder {
    /// Subset `in` filter.
    @discardableResult
    public func filter<T>(_ field: KeyPath<Model, T>, in values: [Model.Database.QueryData]) -> Self
        where T: KeyStringDecodable
    {
        let filter = QueryFilter<Model.Database>(
            entity: Model.entity,
            method: .subset(field.makeQueryField(), .in, .array(values))
        )
        return addFilter(filter)
    }

    /// Subset `notIn` filter.
    @discardableResult
    public func filter<T>(_ field: KeyPath<Model, T>, notIn values: [Model.Database.QueryData]) -> Self
        where T: KeyStringDecodable
    {
        let filter = QueryFilter<Model.Database>(
            entity: Model.entity,
            method: .subset(field.makeQueryField(), .notIn, .array(values))
        )
        return addFilter(filter)
    }
}

/// MARK: Joined

extension QueryBuilder {
    /// Subset `in` filter.
    @discardableResult
    public func filter<M, T>(_ joined: M.Type, _ field: KeyPath<M, T>, in values: [Model.Database.QueryData]) -> Self
        where T: KeyStringDecodable, M: Fluent.Model, M.Database == Model.Database
    {
        let filter = QueryFilter<Model.Database>(
            entity: Model.entity,
            method: .subset(field.makeQueryField(), .in, .array(values))
        )
        return addFilter(filter)
    }

    /// Subset `notIn` filter.
    @discardableResult
    public func filter<M, T>(_ joined: M.Type, _ field: KeyPath<M, T>, notIn values: [Model.Database.QueryData]) -> Self
        where T: KeyStringDecodable, M: Fluent.Model, M.Database == Model.Database
    {
        let filter = QueryFilter<Model.Database>(
            entity: Model.entity,
            method: .subset(field.makeQueryField(), .notIn, .array(values))
        )
        return addFilter(filter)
    }
}

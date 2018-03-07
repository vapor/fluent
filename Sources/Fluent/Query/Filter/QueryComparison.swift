import CodableKit

/// Supported filter comparison types.
public enum QueryComparison {
    /// ==
    case equals
    /// !=
    case notEquals
    /// >
    case greaterThan
    /// <
    case lessThan
    /// >=
    case greaterThanOrEquals
    /// <=
    case lessThanOrEquals
}

/// Supported values for QueryComparison.
public enum QueryComparisonValue<Database> where Database: QuerySupporting {
    /// A concrete value.
    case value(Database.QueryData)
    /// Another query field.
    case field(QueryField)
}

extension QueryBuilder {
    /// Applies a comparison filter to this query.
    @discardableResult
    public func filter(
        entity: String = Model.entity,
        _ field: QueryField,
        _ comparison: QueryComparison,
        _ value: QueryComparisonValue<Model.Database>
    ) -> Self {
        let filter = QueryFilter(entity: entity, method: .compare(field, comparison, value))
        return addFilter(filter)
    }
}

/// MARK: ModelFilterMethod

extension QueryBuilder {
    /// Applies a filter from one of the filter operators (==, !=, etc)
    /// note: this method is generic, allowing you to omit type names
    /// when filtering using key paths.
    @discardableResult
    public func filter(_ value: ModelFilterMethod<Model>) -> Self {
        let filter = QueryFilter(entity: Model.entity, method: value.method)
        return addFilter(filter)
    }
}

/// Typed wrapper around query filter methods.
public struct ModelFilterMethod<M> where M: Model, M.Database: QuerySupporting {
    /// The wrapped query filter method.
    public let method: QueryFilterMethod<M.Database>

    /// Creates a new model filter method.
    public init(method: QueryFilterMethod<M.Database>) {
        self.method = method
    }
}

/// Model.field == value
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Model.Database.QueryData) -> ModelFilterMethod<Model>
    where Value: KeyStringDecodable
{
    return ModelFilterMethod<Model>(method: .compare(lhs.makeQueryField(), .equals, .value(rhs)))
}

/// Model.field != value
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Model.Database.QueryData) -> ModelFilterMethod<Model>
    where Value: KeyStringDecodable {
        return ModelFilterMethod<Model>(method: .compare(lhs.makeQueryField(), .notEquals, .value(rhs)))
}

/// Model.field > value
public func > <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Model.Database.QueryData) -> ModelFilterMethod<Model>
    where Value: KeyStringDecodable
{
    return ModelFilterMethod<Model>(method: .compare(lhs.makeQueryField(), .greaterThan, .value(rhs)))
}

/// Model.field > value
public func < <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Model.Database.QueryData) -> ModelFilterMethod<Model>
    where Value: KeyStringDecodable
{
    return ModelFilterMethod<Model>(method: .compare(lhs.makeQueryField(), .lessThan, .value(rhs)))
}

/// Model.field >= value
public func >= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Model.Database.QueryData) throws -> ModelFilterMethod<Model>
    where Value: KeyStringDecodable
{
    return ModelFilterMethod<Model>(method: .compare(lhs.makeQueryField(), .greaterThanOrEquals, .value(rhs)))
}

/// Model.field <= value
public func <= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Model.Database.QueryData) -> ModelFilterMethod<Model>
    where Value: KeyStringDecodable
{
    return ModelFilterMethod<Model>(method: .compare(lhs.makeQueryField(), .lessThanOrEquals, .value(rhs)))
}


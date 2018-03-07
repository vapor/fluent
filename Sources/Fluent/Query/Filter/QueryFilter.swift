/// Defines a `Filter` that can be
/// added on fetch, delete, and update
/// operations to limit the set of
/// data affected.
public struct QueryFilter<Database> where Database: QuerySupporting {
    /// The entity to filter.
    public var entity: String

    /// The method to filter by, comparison, subset, grouped, etc.
    public var method: QueryFilterMethod<Database>

    /// Create a new filter.
    public init(entity: String, method: QueryFilterMethod<Database>) {
        self.entity = entity
        self.method = method
    }
}

/// Supported Fluent filter methods.
public enum QueryFilterMethod<Database> where Database: QuerySupporting {
    /// Compare a field to another field or value.
    case compare(QueryField, QueryComparison, QueryComparisonValue<Database>)
    /// Compare a field to a set of values, or a subquery.
    case subset(QueryField, QuerySubsetScope, QuerySubsetValue<Database>)
    /// A group of filter methods, related by AND or OR.
    case group(QueryGroupRelation, [QueryFilter<Database>])
}

extension QueryFilter: CustomStringConvertible {
    /// A readable description of this filter.
    public var description: String {
        switch method {
        case .compare(let field, let comparison, let value):
            return "(\(entity)) \(field) \(comparison) \(value)"
        case .subset(let field, let scope, let values):
            return "(\(entity)) \(field) \(scope) \(values)"
        case .group(let relation, let filters):
            return filters.map { $0.description }.joined(separator: "\(relation)")
        }
    }
}

extension QueryBuilder {
    /// Manually create and append filter
    @discardableResult
    public func addFilter(_ filter: QueryFilter<Model.Database>) -> Self {
        query.filters.append(filter)
        return self
    }
}

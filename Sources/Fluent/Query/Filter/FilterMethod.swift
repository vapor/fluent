/// Types of fluent filters.
public enum QueryFilterMethod<Database> where Database: QuerySupporting {
    case compare(QueryField, QueryComparison, QueryComparisonValue)
    case subset(QueryField, QuerySubsetScope, QuerySubsetValue<Database>)
    case group(QueryGroupRelation, [QueryFilter<Database>])
}

public enum QueryComparison {
    case equality(EqualityComparison) // Encodable & Equatable
    case order(OrderedComparison) // Encodable & Comparable
    case sequence(SequenceComparison) // Encodable & Sequence
}

public enum QueryComparisonValue {
    case value(Encodable)
    case field(QueryField)
}

/// Generic filter method acceptors.
extension QueryBuilder {
    /// Applies a filter from one of the filter operators (==, !=, etc)
    /// note: this method is generic, allowing you to omit type names
    /// when filtering using key paths.
    @discardableResult
    public func filter(
        _ value: ModelFilterMethod<Model>
    ) -> Self {
        let filter = QueryFilter(entity: Model.entity, method: value.method)
        return addFilter(filter)
    }
}

/// Typed wrapper around query filter methods.
public struct ModelFilterMethod<M> where M: Model , M.Database: QuerySupporting {
    /// The wrapped query filter method.
    public let method: QueryFilterMethod<M.Database>

    /// Creates a new model filter method.
    public init(method: QueryFilterMethod<M.Database>) {
        self.method = method
    }
}

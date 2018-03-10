import CodableKit

/// GROUP BY statement for QueryBuilder
public enum QueryGroupBy {
    case field(QueryField)
}

// MARK: Builder

extension QueryBuilder {
    /// Add a Group By to the Query.
    public func groupBy<T>(_ field: KeyPath<Model, T>) -> Self
        where T: KeyStringDecodable
    {
        let groupBy = QueryGroupBy.field(field.makeQueryField())
        return self.groupBy(groupBy)
    }
    
    /// Add a Group By to the Query.
    public func groupBy(_ groupBy: QueryGroupBy) -> Self {
        query.groups.append(groupBy)
        return self
    }
}


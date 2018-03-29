/// GROUP BY statement for QueryBuilder
public struct QueryGroupBy {
    enum Storage {
        case field(QueryField)
    }
    
    /// Internal storage
    let storage: Storage
    
    /// Returns the `QueryField` value
    public func field() -> QueryField? {
        switch storage {
        case .field(let field): return field
        }
    }
    
    /// Generates QueryGroupBy object for a field
    public static func field(_ field: QueryField) -> QueryGroupBy { return .init(storage: .field(field)) }
}

// MARK: Builder

extension QueryBuilder {
    /// Add a Group By to the Query.
    public func group<T>(by field: KeyPath<Model, T>) throws -> Self {
        let groupBy = try QueryGroupBy.field(field.makeQueryField())
        return self.group(by: groupBy)
    }
    
    /// Add a Group By to the Query.
    public func group(by groupBy: QueryGroupBy) -> Self {
        query.groups.append(groupBy)
        return self
    }
}

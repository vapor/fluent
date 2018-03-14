import CodableKit

/// GROUP BY statement for QueryBuilder
public struct QueryGroupBy {
    public enum Storage {
        case field(QueryField)
    }
    
    /// Internal storage
    public let storage: Storage
    
    /// Generates QueryGroupBy object for a field
    public static func field(_ field: QueryField) -> QueryGroupBy { return .init(storage: .field(field)) }
    
}

// MARK: Builder

extension QueryBuilder {
    /// Add a Group By to the Query.
    public func group<T>(by field: KeyPath<Model, T>) throws -> Self where T: KeyStringDecodable {
        let groupBy = try QueryGroupBy.field(field.makeQueryField())
        return self.group(by: groupBy)
    }
    
    /// Add a Group By to the Query.
    public func group(by groupBy: QueryGroupBy) -> Self {
        query.groups.append(groupBy)
        return self
    }
}

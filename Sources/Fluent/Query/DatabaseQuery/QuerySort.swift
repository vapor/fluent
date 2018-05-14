extension DatabaseQuery {
    /// Sorts results based on a field and direction.
    public struct Sort {
        /// The types of directions
        /// fields can be sorted.
        public enum Direction {
            case ascending
            case descending
        }

        /// The field to sort.
        public let field: QueryField

        /// The direction to sort by.
        public let direction: Direction

        /// Create a new sort
        public init(field: QueryField, direction: Direction) {
            self.field = field
            self.direction = direction
        }
    }
}

// MARK: Builder

extension QueryBuilder {
    /// Add a Sort to the Query.
    public func sort<T>(_ field: KeyPath<Model, T>, _ direction: DatabaseQuery<Model.Database>.Sort.Direction = .ascending) throws -> Self {
        return try addSort(.init(field: field.makeQueryField(), direction: direction))
    }
    
    /// Add a Sort to the Query.
    public func addSort(_ sort: DatabaseQuery<Model.Database>.Sort) -> Self {
        query.sorts.append(sort)
        return self
    }
}

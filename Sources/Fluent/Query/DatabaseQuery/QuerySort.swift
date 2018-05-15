extension DatabaseQuery {
    /// Sorts results based on a field and direction.
    public struct Sort {
        /// The types of directions
        /// fields can be sorted.
        public enum Direction {
            /// Minimum sorted values will appear first.
            case ascending
            /// Maximum sorted values will appear first.
            case descending
        }

        /// The field to sort.
        public let field: Database.QueryField

        /// The direction to sort by.
        public let direction: Direction

        /// Create a new sort.
        ///
        /// - parameters:
        ///     - field: Query field to sort by.
        ///     - direction: Sort direction, ascending or descending.
        public init(field: Database.QueryField, direction: Direction) {
            self.field = field
            self.direction = direction
        }
    }
}

// MARK: Builder

extension QueryBuilder {
    /// Add a sort to the query builder for a field.
    ///
    ///     let users = try User.query(on: conn).sort(\.name, .ascending)
    ///
    /// - parameters:
    ///     - field: Swift `KeyPath` to field on model to sort.
    ///     - direction: Direction to sort the fields, ascending or descending.
    /// - returns: Query builder for chaining.
    public func sort<T>(_ field: KeyPath<Model, T>, _ direction: DatabaseQuery<Model.Database>.Sort.Direction = .ascending) throws -> Self {
        return try addSort(.init(field: Model.Database.queryField(for: field), direction: direction))
    }

    /// Adds a custom sort to the query builder.
    ///
    /// - parameters:
    ///     - sort: Custom sort to add.
    /// - returns: Query builder for chaining.
    public func addSort(_ sort: DatabaseQuery<Model.Database>.Sort) -> Self {
        query.sorts.append(sort)
        return self
    }
}

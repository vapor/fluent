public protocol QuerySort {
    associatedtype Field: PropertySupporting
    associatedtype Direction: QuerySortDirection
    static func unit(_ field: Field, _ direction: Direction) -> Self
}

public protocol QuerySortDirection {
    static var fluentAscending: Self { get }
    static var fluentDescending: Self { get }
}

extension QueryBuilder {
    // MARK: Sort

    /// Add a sort to the query builder for a field.
    ///
    ///     let users = try User.query(on: conn).sort(\.name, .ascending)
    ///
    /// - parameters:
    ///     - field: Swift `KeyPath` to field on model to sort.
    ///     - direction: Direction to sort the fields, ascending or descending.
    /// - returns: Query builder for chaining.
    public func sort<T>(_ field: KeyPath<Model, T>, _ direction: Model.Database.Query.Sort.Direction = .fluentAscending) -> Self {
        return addSort(.unit(.keyPath(field), direction))
    }

    /// Adds a custom sort to the query builder.
    ///
    /// - parameters:
    ///     - sort: Custom sort to add.
    /// - returns: Query builder for chaining.
    public func addSort(_ sort: Model.Database.Query.Sort) -> Self {
        query.fluentSorts.append(sort)
        return self
    }
}

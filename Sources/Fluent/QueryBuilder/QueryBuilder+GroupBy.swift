public protocol GroupBySupporting: QuerySupporting
    where Query: GroupBysContaining { }

public protocol GroupBysContaining: Query {
    associatedtype GroupBy: QueryGroupBy
        where GroupBy.Field == Field
    var groupBys: [GroupBy] { get set }
}

public protocol QueryGroupBy {
    associatedtype Field
    static func fluentGroupBy(field: Field) -> Self
}

extension QueryBuilder where Model.Database: GroupBySupporting {
    /// Adds a group by to the query builder.
    ///
    ///     query.groupBy(\.name)
    ///
    /// - parameters:
    ///     - field: Swift `KeyPath` to field on model to group by.
    /// - returns: Query builder for chaining.
    public func groupBy<T>(_ field: KeyPath<Model, T>) -> Self {
        return addGroupBy(.fluentGroupBy(field: .keyPath(field)))
    }

    /// Adds a manually created group by to the query builder.
    /// - parameters:
    ///     - groupBy: New `Query.GroupBy` to add.
    /// - returns: Query builder for chaining.
    public func addGroupBy(_ groupBy: Model.Database.Query.GroupBy) -> Self {
        query.groupBys.append(groupBy)
        return self
    }

}

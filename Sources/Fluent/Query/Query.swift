public protocol Query {
    /// Type input into this query when creating or updating data.
    /// Encoded by `queryEncode(...)` method on `QuerySupporting`.
    associatedtype Data

    /// Associated `QueryAction` type. Determines the type of query.
    associatedtype Action: QueryAction

    /// Associated `QueryFilter` type. Used to filter query builders.
    associatedtype Filter: QueryFilter

    /// Associated `QueryKey` type. Used for reading computed or generated query data.
    associatedtype Key: QueryKey

    /// Associated `QueryRange` type. Used to limit query builder result set.
    associatedtype Range: QueryRange

    /// Associated `QuerySort` type. Used to sort query builder results.
    associatedtype Sort: QuerySort

    /// Creates a new instance of self using the supplied entity `String`.
    static func fluentQuery(_ entity: String) -> Self

    /// Query action to perform. See `QueryAction`.
    var fluentAction: Action { get set }

    /// Data to create or update.
    var fluentData: Data { get set }

    /// Result set filters. See `QueryFilter`.
    var fluentFilters: [Filter] { get set }

    /// Fields (including computed) to read. See `QueryKey`.
    var fluentKeys: [Key] { get set }

    /// Limits amount of results. See `QueryRange`.
    var fluentRange: Range? { get set }

    /// Sorts results. See `QuerySort.`
    var fluentSorts: [Sort] { get set }
}

public protocol Query {
    /// Type input into this query when creating or updating data.
    /// Encoded by `queryEncode(...)` method on `QuerySupporting`.
    associatedtype Input

    /// Type returned by this query when reading data. Result set type.
    /// Decoded by `queryDecode(...)` method on `QuerySupporting`.
    associatedtype Output

    /// Associated `QueryAction` type. Determines the type of query.
    associatedtype Action: QueryAction

    /// Associated `QueryData` type. Compatible data type.
    associatedtype Data: QueryData

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

    /// Bound data values. See `QueryData`.
    var fluentBinds: [Data] { get set }

    /// Data to create or update.
    var fluentData: Input { get set }

    /// Result set filters. See `QueryFilter`.
    var fluentFilters: [Filter] { get set }

    /// Fields (including computed) to read. See `QueryKey`.
    var fluentKeys: [Key] { get set }

    /// Limits amount of results. See `QueryRange`.
    var fluentRange: Range? { get set }

    /// Sorts results. See `QuerySort.`
    var fluentSorts: [Sort] { get set }
}

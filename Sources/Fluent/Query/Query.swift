public protocol Query {
    associatedtype Action: QueryAction
    associatedtype Field: QueryField
    associatedtype Filter: QueryFilter
        where Filter.Field == Field
    associatedtype Data: QueryData
    associatedtype Key: QueryKey
        where Key.Field == Field
    associatedtype Range: QueryRange
    associatedtype Sort: QuerySort

    static func fluentQuery(_ entity: String) -> Self

    var fluentAction: Action { get set }
    var fluentBinds: [Data] { get set }
    var fluentData: [Field: Data] { get set}
    var fluentFilters: [Filter] { get set}
    var fluentKeys: [Key] { get set }
    var fluentRanges: [Range] { get set }
    var fluentSorts: [Sort] { get set }
}

///// A query that can be sent to a Fluent database.
//public struct Query<Database> where Database: QuerySupporting {
//    /// Table / collection to query.
//    public let entity: String
//
//    /// CURD action to perform on the database.
//    public var action: Database.Action
//
//    /// Bound data to serialize.
//    public var binds: [Database.Data]
//
//    public var keys: [Database.Key]
//
//    public var data: [Database.Field: Database.Data]
//
//    /// Result set will be limited by these filters.
//    public var filters: [Database.Filter]
//
//    /// One or more group bys to filter by.
//    public var groups: [GroupBy]
//
//    /// If `true`, the query will only select distinct rows.
//    public var isDistinct: Bool
//
//    /// Limits and offsets the amount of results.
//    public var range: Range?
//
//    public var sorts: [Database.Sort]
//
//    /// Allows extensions to store properties.
//    public var extend: Extend
//
//    /// Create a new database query.
//    public init(entity: String) {
//        self.entity = entity
//        self.action = .fluentRead
//        self.binds = []
//        self.keys = [.fluentAll]
//        self.data = [:]
//        self.filters = []
//        self.groups = []
//        self.isDistinct = false
//        self.range = nil
//        self.extend = [:]
//        self.joins = []
//        self.sorts = []
//    }
//}

/// Helper for constructing and executing `DatabaseQuery`s.
///
/// Query builder has methods like `all()`, `first()`, and `chunk(max:closure:)` for fetching data. Use the
/// `filter(...)` methods combined with operators like `==` and `>=` to filter the result set.
///
///     let users = try User.query(on: req).filter(\.name == "Vapor").all()
///
/// Use the `query(on:)` on `Model` to create a `QueryBuilder` for a model.
///
/// You can also use the `update(...)` and `delete(...)` methods to perform batch updates and deletes of entities.
///
/// Query builder is generic across two types: a model and a result. The `Model` is a Fluent model that references
/// the main table / collection this query should take place on. The `Result` is the type that will be returned
/// by the Query builder's execution methods. By default, the Model and the Result will be the same. However, decoding
/// different types can be useful for situations like joins where the result set structure may be different from the model.
///
/// Use methods `decode(...)` and `alsoDecode(...)` to change which result types will be decoded.
///
///     let joined = try User.query(on: req)
///         .join(Pet.self, field: \.userID, to: \.id)
///         .alsoDecode(Pet.self)
///         .all()
///     print(joined) // Future<[(User, Pet)]>
///
public final class QueryBuilder<Model, Result>
    where Model: Fluent.Model, Model.Database: QuerySupporting
{
    /// The `DatabaseQuery` being built.
    public var query: Model.Database.Query

    /// The connection this query will be excuted on.
    /// - warning: Avoid using the connection manually.
    public let connection: Future<Model.Database.Connection>

    /// Current result transformation.
    internal var resultTransformer: (Model.Database.Output, Model.Database.Connection) -> Future<Result>

    /// If `true`, soft deleted models will be included.
    internal var shouldIncludeSoftDeleted: Bool

    /// Create a new `QueryBuilder`.
    /// Use `Model.query(on:)` instead.
    internal init(
        query: Model.Database.Query,
        on connection: Future<Model.Database.Connection>,
        resultTransformer: @escaping (Model.Database.Output, Model.Database.Connection) -> Future<Result>
    ) {
        self.query = query
        self.connection = connection
        self.resultTransformer = resultTransformer
        self.shouldIncludeSoftDeleted = false
    }
}

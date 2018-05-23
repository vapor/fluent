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
    internal var resultTransformer: (Model.Database.Query.Output, Model.Database.Connection) -> Future<Result>

    /// If `true`, soft deleted models will be included.
    internal var shouldIncludeSoftDeleted: Bool

    /// Create a new `QueryBuilder`.
    /// Use `Model.query(on:)` instead.
    internal init(
        query: Model.Database.Query,
        on connection: Future<Model.Database.Connection>,
        resultTransformer: @escaping (Model.Database.Query.Output, Model.Database.Connection) -> Future<Result>
    ) {
        self.query = query
        self.connection = connection
        self.resultTransformer = resultTransformer
        self.shouldIncludeSoftDeleted = false
    }
}

/// Helper for constructing and executing `Database.Query`s.
///
/// Query builder has methods like `all()`, `first()`, and `chunk(max:closure:)` for fetching data. Use the
/// `filter(...)` methods combined with operators like `==` and `>=` to filter the result set.
///
///     let users = try User.query(on: req).filter(\.name == "Vapor").all()
///
/// Use the `query(on:)` on `Model` to create a `QueryBuilder` for a model.
public final class QueryBuilder<Database, Result> where Database: QuerySupporting {
    /// The `DatabaseQuery` being built.
    public var query: Database.Query

    /// The connection this query will be excuted on.
    /// - warning: Avoid using the connection manually.
    public let connection: Future<Database.Connection>

    /// Current result transformation.
    internal var resultTransformer: (Database.Output, Database.Connection) -> Future<Result>

    /// Create a new `QueryBuilder`.
    /// Use `Model.query(on:)` instead.
    internal init(
        query: Database.Query,
        on connection: Future<Database.Connection>,
        resultTransformer: @escaping (Database.Output, Database.Connection) -> Future<Result>
    ) {
        self.query = query
        self.connection = connection
        self.resultTransformer = resultTransformer
    }
}

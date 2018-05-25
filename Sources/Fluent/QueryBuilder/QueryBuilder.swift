
/// let cache = Pet.eagerLoadCache()
/// let users = User.query(on: req).eagerLoad(\.pet, into: cache).all()
/// for user in users {
///     let pets = user.pet.fetch(from: cache)
/// }

public struct EagerLoadRequest<Model>
    where Model: Fluent.Model, Model.Database: QuerySupporting
{
    let closure: ([Model.ID], Model.Database.Connection) -> Future<Void>
}

public final class EagerLoadCache<Model>
    where Model: Fluent.Model, Model.Database: QuerySupporting
{
    var data: [Model]
    init() {
        self.data = []
    }
}

public struct EagerLoad<A, B> where A: Model, B: Model, A.Database: QuerySupporting, B.Database: QuerySupporting {
    public let request: EagerLoadRequest<A>
    public let cache: EagerLoadCache<B>
}

extension Model {
    public static func eagerLoad<Child>(children parentID: KeyPath<Child, Self.ID?>) -> EagerLoad<Self, Child>
        where Child: Model, Child.Database == Database, Child.ID: Hashable
    {
        let cache: EagerLoadCache<Child> = .init()
        let req: EagerLoadRequest<Self> = .init { ids, conn in
            return Child.query(on: conn).filter(parentID ~~ ids).all().map { rows -> Void in
                cache.data = rows
            }
        }
        return .init(request: req, cache: cache)
    }
}

extension QueryBuilder where Model == Result {
    public func all(eagerLoading: EagerLoadRequest<Model>...) -> Future<[Model]> {
        return connection.flatMap { conn in
            return self.all().flatMap { rows in
                let ids: [Model.ID] = try rows.map { try $0.requireID() }
                return eagerLoading.map { $0.closure(ids, conn) }
                    .flatten(on: conn)
                    .transform(to: rows)
            }
        }
    }
}

extension Children {
    public func get(from cache: EagerLoadCache<Child>) throws -> [Child] {
        return try cache.data.filter  { child in
            switch parentID {
            case .optional(let parentID): return try child[keyPath: parentID] == parent.requireID()
            case .required(let parentID): return try child[keyPath: parentID] == parent.requireID()
            }
        }
    }
}

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
    /// Convenience type to access model database.
    public typealias Database = Model.Database

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

/// A query that can be sent to a Fluent database.
public struct Query<Database> where Database: QuerySupporting {
    /// CRUD operations that can be performed on the database.
    public enum Action {
        /// Saves new data to the database.
        case create
        /// Reads existing data from the database.
        case read
        /// Updates existing data from the database.
        case update
        /// Deletes existing data from the database.
        case delete
    }
    
    public enum Field {
        case field(FieldKeyPath)
        case custom(Database.FieldType)
        case reflected(ReflectedProperty, entity: String)

        public static func keyPath<R,V>(_ keyPath: KeyPath<R, V>) -> Field {
            return .field(FieldKeyPath(rootType: R.self, valueType: V.self, keyPath: keyPath))
        }
    }

    public struct FieldKeyPath {
        public var rootType: Any.Type
        public var valueType: Any.Type
        public var keyPath: AnyKeyPath
    }

    public enum Entity {
        case encodable(Encodable)
        case field(Field, Value)
        case custom(Database.EntityType)
        case none
    }
    
    public enum Value {
        case field(FieldKeyPath)
        case encodables([Encodable])
        case custom(Database.ValueType)

        public static func encodable(_ encodable: Encodable) -> Value {
            return .encodables([encodable])
        }

        public static func keyPath<R,V>(_ keyPath: KeyPath<R, V>) -> Value {
            return .field(FieldKeyPath(rootType: R.self, valueType: V.self, keyPath: keyPath))
        }
    }

    /// Table / collection to query.
    public let entity: String

    /// CURD action to perform on the database.
    public var action: Action

    /// Aggregates / computed methods.
    public var aggregates: [Aggregate]

    /// Optional model data to create or update.
    /// Defaults to an empty dictionary.
    public var data: Entity

    /// Result set will be limited by these filters.
    public var filters: [Filter]
    
    /// One or more group bys to filter by.
    public var groups: [GroupBy]

    /// If `true`, the query will only select distinct rows.
    public var isDistinct: Bool

    /// Limits and offsets the amount of results.
    public var range: Range?

    /// Sorts to be applied to the results.
    public var sorts: [Sort]

    /// Joined models.
    public var joins: [Join]

    /// Allows extensions to store properties.
    public var extend: Extend

    /// Create a new database query.
    public init(entity: String) {
        self.entity = entity
        self.action = .read
        self.filters = []
        self.sorts = []
        self.groups = []
        self.aggregates = []
        self.isDistinct = false
        self.data = .none
        self.range = nil
        self.extend = [:]
        self.joins = []
    }

    // MARK: Builder
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
    public final class Builder<Model, Result> where Model: Fluent.Model, Model.Database == Database {
        // MARK: Properties

        /// The `DatabaseQuery` being built.
        public var query: Query

        /// The connection this query will be excuted on.
        /// - warning: Avoid using the connection manually.
        public let connection: Future<Model.Database.Connection>

        /// Current result transformation.
        internal var resultTransformer: (Model.Database.EntityType, Model.Database.Connection) -> Future<Result>

        /// Create a new `QueryBuilder`.
        /// Use `Model.query(on:)` instead.
        internal init(
            query: Query,
            on connection: Future<Model.Database.Connection>,
            resultTransformer: @escaping (Model.Database.EntityType, Model.Database.Connection) -> Future<Result>
        ) {
            self.query = query
            self.connection = connection
            self.resultTransformer = resultTransformer
        }
    }
}

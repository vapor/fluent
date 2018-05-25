/// Represents a single table / collection in a Fluent database. Models
/// are the basis for querying databases (create, read, update, and delete).
///
/// Models can also conform to `Migration` to providing prepare and
/// revert methods for `SchemaSupporting` databases.
///
/// Both `struct`s and `class`es can be models. Since Fluent is closure-based,
/// copied `struct`s will be returned by any methods that must mutate the model.
///
/// Here is an example of a simple `User` model.
///
///     final class User: Model {
///         typealias Database = PostgreSQLDatabase
///         static let idKey: WritableKeyPath<User, UUID?> = \.id
///         var id: UUID?
///         var name: String
///
///         init(id: UUID? = nil, name: String) {
///             self.id = id
///             self.name = name
///         }
///     }
///
/// To create a `QueryBuilder` for a model, use the `query(on:)` method.
///
///     let users = try User.query(on: req).filter(\.name == "Vapor").all()
///
/// Models can also implement optional lifecycle methods to hook into Fluent actions.
///
///     final class User: Model {
///         ...
///         func willDelete(on conn: PostgreSQLConnection) throws -> Future<User> {
///             print("Deleting user: \(id)")
///             return conn.eventLoop.newSucceededFuture(result: self)
///         }
///     }
///
public protocol Model: AnyModel, Reflectable {
    // MARK: DB

    /// The type of database this model can be queried on.
    associatedtype Database: Fluent.Database

    // MARK: ID

    /// The associated Identifier type. Usually `Int` or `UUID`. Must conform to `ID`.
    associatedtype ID: Fluent.ID

    /// Typealias for Swift `KeyPath` to an optional ID for this model.
    typealias IDKey = WritableKeyPath<Self, ID?>

    /// Swift `KeyPath` to this `Model`'s identifier.
    static var idKey: IDKey { get }

    // MARK: Lifecycle

    /// Called before a model is created when saving.
    /// - note: Throwing will cancel the save.
    /// - parameters:
    ///     - conn: Current database connection.
    func willCreate(on conn: Database.Connection)  throws -> Future<Self>
    /// Called after the model is created when saving.
    /// - parameters:
    ///     - conn: Current database connection.
    func didCreate(on conn: Database.Connection) throws -> Future<Self>

    /// Called before a model is fetched.
    /// - note: Throwing will cancel the fetch.
    /// - parameters:
    ///     - conn: Current database connection.
    func willRead(on conn: Database.Connection)  throws -> Future<Self>

    /// Called before a model is updated when saving.
    /// - note: Throwing will cancel the save.
    /// - parameters:
    ///     - conn: Current database connection.
    func willUpdate(on conn: Database.Connection) throws -> Future<Self>
    /// Called after the model is updated when saving.
    /// - parameters:
    ///     - conn: Current database connection.
    func didUpdate(on conn: Database.Connection) throws -> Future<Self>

    /// Called before a model is deleted.
    /// - note: Throwing will cancel the delete.
    /// - parameters:
    ///     - conn: Current database connection.
    func willDelete(on conn: Database.Connection) throws -> Future<Self>
    /// Called after the model is deleted.
    /// - parameters:
    ///     - conn: Current database connection.
    func didDelete(on conn: Database.Connection) throws -> Future<Self>


    /// Called before a model is restored (from being soft deleted).
    /// - note: Throwing will cancel the restore.
    /// - parameters:
    ///     - conn: Current database connection.
    func willRestore(on conn: Database.Connection) throws -> Future<Self>
    /// Called after the model is restored (from being soft deleted.
    /// - parameters:
    ///     - conn: Current database connection.
    func didRestore(on conn: Database.Connection) throws -> Future<Self>


    /// Called before a model is soft deleted.
    /// - note: Throwing will cancel the soft delete.
    /// - parameters:
    ///     - conn: Current database connection.
    func willSoftDelete(on conn: Database.Connection) throws -> Future<Self>
    /// Called after the model is soft deleted.
    /// - parameters:
    ///     - conn: Current database connection.
    func didSoftDelete(on conn: Database.Connection) throws -> Future<Self>
}

// MARK: Optional

extension Model {
    /// See `Model`.
    public func willCreate(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }

    /// See `Model`.
    public func didCreate(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }

    /// See `Model`.
    public func willUpdate(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `Model`.
    public func didUpdate(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }

    /// See `Model`.
    public func willRead(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }

    /// See `Model`.
    public func willDelete(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `Model`.
    public func didDelete(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }

    /// See `Model`.
    public func willRestore(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `Model`.
    public func didRestore(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `Model`.
    public func willSoftDelete(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
    /// See `Model`.
    public func didSoftDelete(on conn: Database.Connection) throws -> Future<Self> {
        return conn.future(self)
    }
}

/// MARK: ID

extension Model {
    /// Returns the model's ID, throwing an error if the model does not yet have an ID.
    public func requireID() throws -> ID {
        guard let id = self.fluentID else {
            throw FluentError(identifier: "idRequired", reason: "\(Self.self) does not have an identifier.")
        }

        return id
    }

    /// Access the Fluent identifier keyed by `idKey`.
    public var fluentID: ID? {
        get {
            let path = Self.idKey
            return self[keyPath: path]
        }
        set {
            let path = Self.idKey
            self[keyPath: path] = newValue
        }
    }
}

// MARK: Query

extension Model where Database: QuerySupporting {
    /// Creates a query for this model on the supplied connection.
    ///
    ///     user.query(on: conn).save(user)
    ///
    /// - parameters:
    ///     - conn: Something `DatabaseConnectable` to create the `QueryBuilder` on.
    public func query(on conn: DatabaseConnectable) -> QueryBuilder<Self, Self> {
        return Self.query(on: conn)
    }

    /// Creates a query for this model type on the supplied connection.
    ///
    ///     let users = try User.query(on: req).filter(\.name == "Vapor").all()
    ///
    /// - parameters:
    ///     - conn: Something `DatabaseConnectable` to create the `QueryBuilder` on.
    public static func query(on conn: DatabaseConnectable) -> QueryBuilder<Self, Self> {
        return query(on: conn.databaseConnection(to: Self.defaultDatabase))
    }

    /// Attempts to find an instance of this model with the supplied identifier.
    ///
    ///     let user = try User.find(42)
    ///
    /// - parameters:
    ///     - id: ID to lookup.
    ///     - conn: Something `DatabaseConnectable` to create the `QueryBuilder` on.
    public static func find(_ id: Self.ID, on conn: DatabaseConnectable) -> Future<Self?> {
        return query(on: conn).filter(idKey == id).first()
    }

    /// Creates a `QueryBuilder` for this model, decoding some non-model decodable type as the result.
    static func query<D>(decoding type: D.Type, on connection: Future<Self.Database.Connection>) -> QueryBuilder<Self, D> where D: Decodable {
        return .make(on: connection) { row, conn in
            return Future.map(on: conn) {
                return try Self.Database.queryDecode(row, entity: entity, as: D.self)
            }
        }
    }

    /// Creates a `QueryBuilder` for this model, decoding instances of this model as the result.
    static func query(on connection: Future<Self.Database.Connection>) -> QueryBuilder<Self, Self> {
        return query(decoding: Self.self, on: connection).transformResult { row, conn, result in
            return Self.Database.modelEvent(event: .willRead, model: result, on: conn).flatMap(to: Self.self) { model in
                return try model.willRead(on: conn)
            }
        }
    }
}

// MARK: Default Database

/// Private static default database storage.
private var _defaultDatabases: [ObjectIdentifier: Any] = [:]

extension Model {
    /// This Model's default database. This will be used
    /// when no database id is passed (for example, on `Model.query(on:)`)
    /// or when it is not possible to pass a database (such as static lookup).
    public static var defaultDatabase: DatabaseIdentifier<Database>? {
        get { return _defaultDatabases[ObjectIdentifier(Self.self)] as? DatabaseIdentifier<Database> }
        set { _defaultDatabases[ObjectIdentifier(Self.self)] = newValue }
    }

    /// Returns the `defaultDatabase` or throws an error.
    public static func requireDefaultDatabase() throws -> DatabaseIdentifier<Database> {
        guard let dbid = Self.defaultDatabase else {
            throw FluentError(
                identifier: "noDefaultDatabase",
                reason: "A default database is required if no database ID is passed to `\(Self.self).query(_:on:)` or if `\(Self.self)` is being looked up statically.",
                suggestedFixes: ["Set `\(Self.self).defaultDatabase` or to fix this error."]
            )
        }
        return dbid
    }
}

// MARK: Routing

extension Model where Database: QuerySupporting {
    /// See `Parameter`.
    public static func make(for parameter: String, using container: Container) throws -> Future<Self> {
        guard let idType = ID.self as? LosslessStringConvertible.Type else {
            throw FluentError(
                identifier: "invalidIDType",
                reason: "Could not convert string to ID.",
                suggestedFixes: ["Conform `\(ID.self)` to `LosslessStringConvertible` to fix this error."]
            )
        }

        guard let id = idType.init(parameter) as? ID else {
            throw FluentError(
                identifier: "invalidID",
                reason: "Could not convert parameter \(parameter) to type `\(ID.self)`"
            )
        }

        func findModel(in connection: Database.Connection) throws -> Future<Self> {
            return self.find(id, on: connection).map(to: Self.self) { model in
                guard let model = model else {
                    throw FluentError(identifier: "modelNotFound", reason: "No model with ID \(id) was found")
                }
                return model
            }
        }

        let dbid = try Self.requireDefaultDatabase()
        if let subcontainer = container as? SubContainer {
            let connection = subcontainer.requestCachedConnection(to: dbid)
            return connection.flatMap(to: Self.self, findModel)
        } else {
            return container.withPooledConnection(to: dbid, closure: findModel)
        }
    }

    /// See `Parameter`.
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> Future<Self> {
        return try make(for: parameter, using: container)
    }
}

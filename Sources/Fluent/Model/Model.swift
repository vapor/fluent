import Async
import Core
import Service

/// Fluent database models. These types can be fetched
/// from a database connection using a query.
///
/// Types conforming to this protocol provide the basis
/// fetching and saving data to/from Fluent.
public protocol Model: AnyModel, Reflectable {
    /// The type of database this model can be queried on.
    associatedtype Database: Fluent.Database

    /// The associated Identifier type.
    /// Usually Int or UUID.
    associatedtype ID: Fluent.ID

    /// Key path to identifier
    typealias IDKey = WritableKeyPath<Self, ID?>

    /// This model's id key.
    /// note: If this is not `id`, you
    /// will still need to implement `var id`
    /// on your model as a computed property.
    static var idKey: IDKey { get }

    /// Called before a model is created when saving.
    /// Throwing will cancel the save.
    func willCreate(on connection: Database.Connection)  throws -> Future<Self>
    /// Called after the model is created when saving.
    func didCreate(on connection: Database.Connection) throws -> Future<Self>

    /// Called before a model is updated when saving.
    /// Throwing will cancel the save.
    func willUpdate(on connection: Database.Connection) throws -> Future<Self>
    /// Called after the model is updated when saving.
    func didUpdate(on connection: Database.Connection) throws -> Future<Self>

    /// Called before a model is fetched.
    /// Throwing will cancel the fetch.
    func willRead(on connection: Database.Connection)  throws -> Future<Self>

    /// Called before a model is deleted.
    /// Throwing will cancel the deletion.
    func willDelete(on connection: Database.Connection) throws -> Future<Self>
}

/// Type-erased model.
/// See Model
public protocol AnyModel: Codable {
    /// This model's unique name.
    static var name: String { get }

    /// This model's collection/table name
    static var entity: String { get }
}

extension Model where Database: QuerySupporting {
    /// Creates a query for this model on the supplied connection.
    public func query(on conn: DatabaseConnectable) -> QueryBuilder<Self, Self> {
        return Self.query(on: conn)
    }

    /// Creates a query for this model on the supplied connection.
    public static func query(on conn: DatabaseConnectable) -> QueryBuilder<Self, Self> {
        return query(on: conn.databaseConnection(to: Self.defaultDatabase))
    }
}

extension Model {
    /// Access the fluent identifier
    public var fluentID: ID? {
        get { return self[keyPath: Self.idKey] }
        set { self[keyPath: Self.idKey] = newValue }
    }
}

/// Free implementations.
extension Model {
    /// See Model.name
    public static var name: String {
        return "\(Self.self)".lowercased()
    }

    /// See Model.entity
    public static var entity: String {
        var pluralName = name.replacingOccurrences(of: "([^aeiouy]|qu)y$", with: "$1ie", options: [.regularExpression])

        if pluralName.last != "s" {
            pluralName += "s"
        }

        return pluralName
    }

    /// Seee Model.willCreate()
    public func willCreate(on connection: Database.Connection) throws -> Future<Self> {
        return Future.map(on: connection) { self }
    }

    /// See Model.didCreate()
    public func didCreate(on connection: Database.Connection) throws -> Future<Self> {
        return Future.map(on: connection) { self }
    }

    /// See Model.willUpdate()
    public func willUpdate(on connection: Database.Connection) throws -> Future<Self> {
        return Future.map(on: connection) { self }
    }
    /// See Model.didUpdate()
    public func didUpdate(on connection: Database.Connection) throws -> Future<Self> {
        return Future.map(on: connection) { self }
    }

    /// See Model.willRead()
    public func willRead(on connection: Database.Connection) throws -> Future<Self> {
        return Future.map(on: connection) { self }
    }

    /// See Model.willDelete()
    public func willDelete(on connection: Database.Connection) throws -> Future<Self> {
        return Future.map(on: connection) { self }
    }
}

/// MARK: Convenience

extension Model {
    /// Returns the ID.
    /// Throws an error if the model doesn't have an ID.
    public func requireID() throws -> ID {
        guard let id = self.fluentID else {
            throw FluentError(identifier: "idRequired", reason: "\(Self.self) does not have an identifier.", source: .capture())
        }

        return id
    }
}

/// MARK: CRUD

extension Model where Database: QuerySupporting {
    /// Saves the supplied model.
    /// Calls `create` if the ID is `nil`, and `update` if it exists.
    /// If you need to create a model with a pre-existing ID,
    /// call `create` instead.
    public func save(on conn: DatabaseConnectable) -> Future<Self> {
        return query(on: conn).save(self)
    }

    /// Saves this model as a new item in the database.
    /// This method can auto-generate an ID depending on ID type.
    public func create(on conn: DatabaseConnectable) -> Future<Self> {
        return query(on: conn).create(self)
    }

    /// Updates the model. This requires that
    /// the model has its ID set.
    public func update(on conn: DatabaseConnectable, originalID: ID? = nil) -> Future<Self> {
        return query(on: conn).update(self, originalID: originalID)
    }

    /// Saves this model to the supplied query executor.
    /// If `shouldCreate` is true, the model will be saved
    /// as a new item even if it already has an identifier.
    public func delete(on conn: DatabaseConnectable) -> Future<Void> {
        return query(on: conn).delete(self)
    }
}

/// MARK: Future CRUD

extension Future where T: Model, T.Database: QuerySupporting {
    /// See `Model.save(on:)`
    public func save(on connectable: DatabaseConnectable) -> Future<T> {
        return self.flatMap(to: T.self) { (model) in
            return model.save(on: connectable).transform(to: model)
        }
    }

    /// See `Model.create(on:)`
    public func create(on connectable: DatabaseConnectable) -> Future<T> {
        return self.flatMap(to: T.self) { (model) in
            return model.create(on: connectable).transform(to: model)
        }
    }

    /// See `Model.update(on:)`
    public func update(on connectable: DatabaseConnectable) -> Future<T> {
        return self.flatMap(to: T.self) { (model) in
            return model.update(on: connectable).transform(to: model)
        }
    }

    /// See `Model.delete(on:)`
    public func delete(on connectable: DatabaseConnectable) -> Future<T> {
        return self.flatMap(to: T.self) { (model) in
            return model.delete(on: connectable).transform(to: model)
        }
    }
}

/// MARK: Find

extension Model where Database: QuerySupporting {
    /// Attempts to find an instance of this model w/
    /// the supplied identifier.
    public static func find(_ id: Self.ID, on conn: DatabaseConnectable) throws -> Future<Self?> {
        return try query(on: conn).filter(idKey, .equals, .data(id)).first()
    }
}

// MARK: Default Database

/// Private static default database storage.
private var _defaultDatabases: [ObjectIdentifier: Any] = [:]

extension Model {
    /// This Model's default database. This will be used
    /// when no database id is passed (for example, on `Model.query(on:)`,
    /// or when it is not possible to pass a database (such as static lookup).
    public static var defaultDatabase: DatabaseIdentifier<Database>? {
        get { return _defaultDatabases[ObjectIdentifier(Self.self)] as? DatabaseIdentifier<Database> }
        set { _defaultDatabases[ObjectIdentifier(Self.self)] = newValue }
    }

    /// Returns the `.defaultDatabase` or throws an error.
    public static func requireDefaultDatabase() throws -> DatabaseIdentifier<Database> {
        guard let dbid = Self.defaultDatabase else {
            throw FluentError(
                identifier: "noDefaultDatabase",
                reason: "A default database is required if no database ID is passed to `\(Self.self).query(_:on:)` or if `\(Self.self)` is being looked up statically.",
                suggestedFixes: ["Set `\(Self.self).defaultDatabase` or to fix this error."],
                source: .capture()
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
                suggestedFixes: ["Conform `\(ID.self)` to `LosslessStringConvertible` to fix this error."],
                source: .capture()
            )
        }

        guard let id = idType.init(parameter) as? ID else {
            throw FluentError(
                identifier: "invalidID",
                reason: "Could not convert parameter \(parameter) to type `\(ID.self)`",
                source: .capture()
            )
        }

        func findModel(in connection: Database.Connection) throws -> Future<Self> {
            return try self.find(id, on: connection).map(to: Self.self) { model in
                guard let model = model else {
                    throw FluentError(identifier: "modelNotFound", reason: "No model with ID \(id) was found", source: .capture())
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

import Async
import Debugging
import Foundation
import Fluent
import Service
import SQLite

/// A SQLite database model.
/// See `Fluent.Model`.
public protocol SQLiteModel: Model where Self.Database == SQLiteDatabase, Self.ID == Int {
    /// This SQLite Model's unique identifier.
    var id: ID? { get set }
}

extension SQLiteModel {
    /// See `Model.ID`
    public typealias ID = Int

    /// See `Model.idKey`
    public static var idKey: IDKey { return \.id }
}

/// A SQLite database pivot.
/// See `Fluent.Pivot`.
public protocol SQLitePivot: Pivot, SQLiteModel { }

/// A SQLite database model.
/// See `Fluent.Model`.
public protocol SQLiteUUIDModel: Model where Self.Database == SQLiteDatabase, Self.ID == UUID {
    /// This SQLite Model's unique identifier.
    var id: UUID? { get set }
}

extension SQLiteUUIDModel {
    /// See `Model.ID`
    public typealias ID = UUID

    /// See `Model.idKey`
    public static var idKey: IDKey { return \.id }
}

/// A SQLite database pivot.
/// See `Fluent.Pivot`.
public protocol SQLiteUUIDPivot: Pivot, SQLiteUUIDModel { }

/// A SQLite database model.
/// See `Fluent.Model`.
public protocol SQLiteStringModel: Model where Self.Database == SQLiteDatabase, Self.ID == String {
    /// This SQLite Model's unique identifier.
    var id: String? { get set }
}

extension SQLiteStringModel {
    /// See `Model.ID`
    public typealias ID = String

    /// See `Model.idKey`
    public static var idKey: IDKey { return \.id }
}

/// A SQLite database pivot.
/// See `Fluent.Pivot`.
public protocol SQLiteStringPivot: Pivot, SQLiteStringModel { }

extension DatabaseIdentifier {
    /// The main SQLite database identifier.
    public static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return .init("sqlite")
    }
}

extension SQLiteDatabase: Database, Service {
    public typealias Connection = SQLiteConnection

    /// See `Database.makeConnection`
    public func makeConnection(
        using config: SQLiteConfig,
        on worker: Worker
    ) -> Future<SQLiteConnection> {
        return self.makeConnection(on: worker)
    }
}

func id(_ type: Any.Type) -> ObjectIdentifier {
    return ObjectIdentifier(type)
}

extension SQLiteDatabase: JoinSupporting {}

public struct SQLiteConfig: Service {
    public init() {}
}

extension SQLiteConnection: DatabaseConnection {
    public typealias Config = SQLiteConfig
    
    public func connect<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection> {
        return Future(self as! D.Connection)
    }
}

extension SQLiteDatabase: LogSupporting {
    /// See SupportsLogging.enableLogging
    public func enableLogging(using logger: DatabaseLogger) {
        self.logger = logger
    }
}

extension DatabaseLogger: SQLiteLogger {
    /// See SQLiteLogger.log
    public func log(query: SQLiteQuery) {
        let log = DatabaseLog(
            query: query.string,
            values: query.binds.map { $0.description }
        )
        record(log: log)
    }
}

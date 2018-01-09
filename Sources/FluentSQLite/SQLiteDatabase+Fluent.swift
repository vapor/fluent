import Async
import Debugging
import Foundation
import Fluent
import SQLite

/// A SQLite database model.
/// See `Fluent.Model`.
public protocol SQLiteModel: Model where Database == SQLiteDatabase { }
extension SQLiteModel {
    public typealias Database = SQLiteDatabase
}

extension DatabaseIdentifier {
    /// The main SQLite database identifier.
    public static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return .init("sqlite")
    }
}

extension SQLiteDatabase: Database {
    public typealias Connection = SQLiteConnection
    
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

public struct SQLiteConfig {
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
import Async
import Debugging
import Foundation
import Fluent
import SQLite

extension SQLiteDatabase: Database {
    public typealias Connection = SQLiteConnection
    
    public func makeConnection(from config: SQLiteConfig, on worker: Worker) -> Future<SQLiteConnection> {
        return self.makeConnection(on: worker)
    }
}

func id(_ type: Any.Type) -> ObjectIdentifier {
    return ObjectIdentifier(type)
}

extension SQLiteDatabase: ReferenceSupporting {}
extension SQLiteDatabase: JoinSupporting {}

public struct SQLiteConfig {
    public init() {}
}

extension SQLiteConnection: DatabaseConnection {
    public typealias Config = SQLiteConfig

    public func existingConnection<D>(to type: D.Type) -> D.Connection? where D: Database {
        return self as? D.Connection
    }
    
    public func connect<D>(to database: DatabaseIdentifier<D>) -> Future<D.Connection> {
        fatalError("Cannot call `.connect(to:)` on an existing connection. Call `.existingConnection` instead.")
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

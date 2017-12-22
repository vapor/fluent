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

extension SQLiteDatabase: QuerySupporting {
    public static func idType<T>(for type: T.Type) -> IDType where T: Fluent.ID {
        switch id(type) {
        case id(Int.self): return .driver
        case id(UUID.self): return .fluent
        default: return .user
        }
    }
}

extension SQLiteDatabase: SchemaSupporting {
    /// See SchemaSupporting.FieldType
    public typealias FieldType = SQLiteFieldType

    public static func dataType(for field: SchemaField<SQLiteDatabase>) -> String {
        var sql: [String] = []
        switch field.type {
        case .blob: sql.append("BLOB")
        case .integer: sql.append("INTEGER")
        case .real: sql.append("REAL")
        case .text: sql.append("TEXT")
        case .null: sql.append("NULL")
        }

        if field.isIdentifier {
            sql.append("PRIMARY KEY")
        }

        if !field.isOptional {
            sql.append("NOT NULL")
        }

        return sql.joined(separator: " ")
    }

    public static func fieldType(for type: Any.Type) throws -> SQLiteFieldType {
        switch id(type) {
        case id(Date.self), id(Double.self), id(Float.self): return .real
        case id(Int.self), id(UInt.self): return .integer
        case id(String.self): return .text
        case id(UUID.self), id(Data.self): return .blob
        default: fatalError("Unsupported SQLite field type")
        }
    }
}

fileprivate func id(_ type: Any.Type) -> ObjectIdentifier {
    return ObjectIdentifier(type)
}

extension SQLiteDatabase: ReferenceSupporting {}
extension SQLiteDatabase: JoinSupporting {}
extension SQLiteDatabase: TransactionSupporting {}

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

/// Errors that can be thrown while working with FluentSQLite.
public struct FluentSQLiteError: Traceable, Debuggable, Swift.Error, Encodable {
    public static let readableName = "Fluent Error"
    public let identifier: String
    public var reason: String
    public var file: String
    public var function: String
    public var line: UInt
    public var column: UInt
    public var stackTrace: [String]
    
    init(
        identifier: String,
        reason: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.identifier = identifier
        self.reason = reason
        self.file = file
        self.function = function
        self.line = line
        self.column = column
        self.stackTrace = FluentSQLiteError.makeStackTrace()
    }
}

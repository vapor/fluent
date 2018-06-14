import Async
import Fluent
import Foundation

public final class LogMessage<D>: Model where D: QuerySupporting {
    /// See Model.Database
    public typealias Database = D

    /// See Model.ID
    public typealias ID = Int

    /// See Model.name
    public static var name: String {
        return "logmessage"
    }

    /// See Model.idKey
    public static var idKey: IDKey { return \.id }

    /// See Model.database
    public static var database: DatabaseIdentifier<D> {
        return .init("test")
    }

    /// LogMessage's identifier
    var id: ID?

    /// Log message
    var message: String

    /// Create a new foo
    init(id: ID? = nil, message: String) {
        self.id = id
        self.message = message
    }
}

internal struct LogMessageMigration<D>: Migration where D: QuerySupporting & SchemaSupporting & MigrationSupporting {
    typealias Database = D

    static func prepare(on connection: D.Connection) -> Future<Void> {
        return Database.create(LogMessage<D>.self, on: connection) { builder in
            builder.field(for: \.id)
            builder.field(for: \.message)
        }
    }

    static func revert(on connection: D.Connection) -> Future<Void> {
        return Database.delete(LogMessage<Database>.self, on: connection)
    }
}

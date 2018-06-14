import Async
import Fluent
import Foundation

final class KitchenSink<D>: Model where D: QuerySupporting {
    /// See Model.Database
    typealias Database = D

    /// See Model.ID
    typealias ID = String

    /// See Model.idKey
    static var idKey: IDKey { return \.id }

    /// KitchenSink's identifier
    var id: String?
    var uuid: UUID
    var string: String
    var int: Int
    var double: Double
    var date: Date
}

internal struct KitchenSinkSchema<D>: Migration where D: QuerySupporting & SchemaSupporting & MigrationSupporting {
    /// See Migration.Database
    typealias Database = D

    /// See Migration.prepare
    static func prepare(on conn: D.Connection) -> Future<Void> {
        return Database.create(KitchenSink<Database>.self, on: conn) { builder in
            builder.field(for: \.uuid)
            builder.field(for: \.string)
            builder.field(for: \.int)
            builder.field(for: \.double)
            builder.field(for: \.date)
        }
    }

    /// See Migration.revert
    static func revert(on conn: D.Connection) -> Future<Void> {
        return Database.delete(KitchenSink<Database>.self, on: conn)
    }
}

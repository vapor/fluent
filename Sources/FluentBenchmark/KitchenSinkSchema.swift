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
}

internal struct KitchenSinkSchema<D>: Migration where D: QuerySupporting & SchemaSupporting {
    /// See Migration.Database
    typealias Database = D

    /// See Migration.prepare
    static func prepare(on conn: D.Connection) -> Future<Void> {
        return Database.create(KitchenSink<Database>.self, on: conn) { builder in
            try builder.addField(
                type: Database.fieldType(for: UUID.self),
                name: "id"
            )
            try builder.addField(
                type: Database.fieldType(for: String.self),
                name: "string"
            )
            try builder.addField(
                type: Database.fieldType(for: Int.self),
                name: "int"
            )
            try builder.addField(
                type: Database.fieldType(for: Double.self),
                name: "double"
            )
            try builder.addField(
                type: Database.fieldType(for: Date.self),
                name: "date"
            )
        }
    }

    /// See Migration.revert
    static func revert(on conn: D.Connection) -> Future<Void> {
        return Database.delete(KitchenSink<Database>.self, on: conn)
    }
}

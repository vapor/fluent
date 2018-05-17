import Async
import Foundation

// MARK: Protocols

/// Capable of executing a database schema query.
public protocol SchemaSupporting: QuerySupporting {
    /// Associated schema type for this database.
    associatedtype SchemaType

    /// Executes the supplied schema on the database connection.
    static func execute(schema: Schema<Self>, on connection: Connection) -> Future<Void>
}

// MARK: Convenience

extension SchemaSupporting {
    /// Convenience for creating a closure that accepts a schema creator
    /// for the supplied model type on this schema executor.
    public static func create<Model>(
        _ model: Model.Type,
        on connection: Connection,
        closure: @escaping (Schema<Self>.Creator<Model>) throws -> ()
    ) -> Future<Void> {
        let creator = Schema<Self>.Creator(Model.self)
        return Future.flatMap(on: connection) {
            try closure(creator)
            return self.execute(schema: creator.schema, on: connection)
        }
    }

    /// Convenience for creating a closure that accepts a schema updater
    /// for the supplied model type on this schema executor.
    public static func update<Model>(
        _ model: Model.Type,
        on connection: Connection,
        closure: @escaping (Schema<Self>.Updater<Model>) throws -> ()
    ) -> Future<Void> {
        let updater = Schema<Self>.Updater(Model.self)
        return Future.flatMap(on: connection) {
            try closure(updater)
            return self.execute(schema: updater.schema, on: connection)
        }
    }

    /// Convenience for deleting the schema for the supplied model type.
    public static func delete<Model>(_ model: Model.Type, on connection: Connection) -> Future<Void>
        where Model: Fluent.Model, Model.Database == Self
    {
        let schema = Schema<Self>(entity: Model.entity, action: .delete)
        return execute(schema: schema, on: connection)
    }
}

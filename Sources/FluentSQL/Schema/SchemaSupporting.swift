import Async
import Foundation

// MARK: Protocols

/// Capable of executing a database schema query.
public protocol SchemaSupporting: QuerySupporting {
    /// Associated schema type for this database.
    associatedtype Schema: FluentSQL.Schema
        where Schema.Field == Query.Field

    /// Enables references errors.
    static func enableReferences(on conn: Connection) -> Future<Void>

    /// Disables reference errors.
    static func disableReferences(on conn: Connection) -> Future<Void>

    /// Executes the supplied schema on the database connection.
    static func execute(schema: Schema, on connection: Connection) -> Future<Void>
}

// MARK: Convenience

extension SchemaSupporting {
    /// Convenience for creating a closure that accepts a schema creator
    /// for the supplied model type on this schema executor.
    public static func create<Model>(
        _ model: Model.Type,
        on connection: Connection,
        closure: @escaping (SchemaCreator<Model>) throws -> ()
    ) -> Future<Void> where Model.Database == Self {
        let creator = SchemaCreator(Model.self)
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
        closure: @escaping (SchemaUpdater<Model>) throws -> ()
    ) -> Future<Void> where Model.Database == Self {
        let updater = SchemaUpdater(Model.self)
        return Future.flatMap(on: connection) {
            try closure(updater)
            return self.execute(schema: updater.schema, on: connection)
        }
    }

    /// Convenience for deleting the schema for the supplied model type.
    public static func delete<Model>(_ model: Model.Type, on connection: Connection) -> Future<Void>
        where Model: Fluent.Model, Model.Database == Self
    {
        var schema: Model.Database.Schema = .fluentSchema(Model.entity)
        schema.fluentAction = .fluentDelete
        return execute(schema: schema, on: connection)
    }
}

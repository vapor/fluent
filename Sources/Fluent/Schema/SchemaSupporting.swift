import Async
import Foundation

// MARK: Protocols

/// Capable of executing a database schema query.
public protocol SchemaSupporting: Database {
    /// See SchemaFieldType
    associatedtype FieldType

    /// Default schema field types Fluent must know
    /// how to make for migrations and tests.
    static func fieldType(for type: Any.Type) throws -> FieldType

    /// Executes the supplied schema on the database connection.
    static func execute(schema: DatabaseSchema<Self>, on connection: Connection) -> Future<Void>
}

// MARK: Convenience

extension SchemaSupporting {
    /// Closure for accepting a schema creator.
    public typealias CreateClosure<Model> = (SchemaCreator<Model>) throws -> ()
        where Model: Fluent.Model, Model.Database: SchemaSupporting

    /// Convenience for creating a closure that accepts a schema creator
    /// for the supplied model type on this schema executor.
    public static func create<Model>(_ model: Model.Type, on connection: Connection, closure: @escaping CreateClosure<Model>) -> Future<Void>
        where Model.Database == Self
    {
        let creator = SchemaCreator(Model.self)
        return Future.flatMap(on: connection) {
            try closure(creator)
            return self.execute(schema: creator.schema, on: connection)
        }
    }

    /// Closure for accepting a schema updater.
    public typealias UpdateClosure<Model> = (SchemaUpdater<Model>) throws -> ()
        where Model: Fluent.Model, Model.Database: SchemaSupporting

    /// Convenience for creating a closure that accepts a schema updater
    /// for the supplied model type on this schema executor.
    public static func update<Model>(_ model: Model.Type, on connection: Connection, closure: @escaping UpdateClosure<Model>) -> Future<Void>
        where Model.Database == Self
    {
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
        let schema = DatabaseSchema<Model.Database>(entity: Model.entity, action: .delete)
        return execute(schema: schema, on: connection)
    }
}

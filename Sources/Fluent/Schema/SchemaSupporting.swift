import Async
import Foundation

// MARK: Protocols

public protocol SchemaExecuting: DatabaseConnection {
    /// Executes the supplied schema on the database connection.
    func execute<D>(schema: DatabaseSchema<D>) -> Future<Void>
}

/// Capable of executing a database schema query.
public protocol SchemaSupporting: Database
    where Self.Connection: SchemaExecuting
{
    /// See SchemaFieldType
    associatedtype FieldType

    /// Serializes the schema field to a string.
    static func dataType(for field: SchemaField<Self>) -> String

    /// Default schema field types Fluent must know
    /// how to make for migrations and tests.
    static func fieldType(for type: Any.Type) throws -> FieldType

}

// MARK: Convenience

extension SchemaExecuting {
    /// Closure for accepting a schema creator.
    public typealias CreateClosure<Model> = (SchemaCreator<Model>) throws -> ()
        where Model: Fluent.Model, Model.Database: SchemaSupporting

    /// Convenience for creating a closure that accepts a schema creator
    /// for the supplied model type on this schema executor.
    public func create<Model>(_ model: Model.Type, closure: @escaping CreateClosure<Model>) -> Future<Void>
        where Model.Database.Connection == Self
    {
        let creator = SchemaCreator(Model.self, on: self)
        return Future {
            try closure(creator)
            return self.execute(schema: creator.schema)
        }
    }

    /// Closure for accepting a schema updater.
    public typealias UpdateClosure<Model> = (SchemaUpdater<Model>) throws -> ()
        where Model: Fluent.Model, Model.Database: SchemaSupporting

    /// Convenience for creating a closure that accepts a schema updater
    /// for the supplied model type on this schema executor.
    public func update<Model>(_ model: Model.Type, closure: @escaping UpdateClosure<Model>) -> Future<Void>
        where Model.Database.Connection == Self
    {
        let updater = SchemaUpdater(Model.self, on: self)
        return Future {
            try closure(updater)
            return self.execute(schema: updater.schema)
        }
    }

    /// Convenience for deleting the schema for the supplied model type.
    public func delete<Model>(_ model: Model.Type) -> Future<Void>
        where Model: Fluent.Model, Model.Database: SchemaSupporting, Model.Database.Connection == Self
    {
        var schema = DatabaseSchema<Model.Database>(entity: Model.entity)
        schema.action = .delete
        return execute(schema: schema)
    }
}

import Async
import Foundation

// MARK: Protocols

/// Capable of executing a database schema query.
public protocol SchemaSupporting: QuerySupporting {
    /// Associated schema type for this database.

    associatedtype FieldDefinition: SchemaFieldDefinition
        where FieldDefinition.Field == Query.Field

    /// Executes the supplied schema on the database connection.
    static func execute(schema: Schema<Self>, on connection: Connection) -> Future<Void>
}

public protocol SchemaFieldDefinition {
    associatedtype Field
    associatedtype DataType: SchemaDataType

    var field: Field { get }
    static func unit(_ field: Field, _ dataType: DataType, isOptional: Bool, isIdentifier: Bool) -> Self
}

public protocol SchemaDataType {
    static func type(_ type: Any.Type) -> Self
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
        let schema = Schema<Self>(entity: Model.entity, action: .delete)
        return execute(schema: schema, on: connection)
    }
}

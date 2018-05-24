/// SQL database.
public protocol SQLDatabase: QuerySupporting & JoinSupporting & MigrationSupporting
    where Query == DataManipulationQuery
{
    /// Determines a `DataDefinitionDataType` for the supplied Swift type.
    static func schemaDataType(for type: Any.Type) -> DataDefinitionDataType

    /// Executes the supplied schema on the database connection.
    static func schemaExecute(_ ddl: DataDefinitionQuery, on connection: Connection) -> Future<Void>

    /// Enables references errors.
    static func enableReferences(on conn: Connection) -> Future<Void>

    /// Disables reference errors.
    static func disableReferences(on conn: Connection) -> Future<Void>
}

// MARK: Convenience

extension SQLDatabase {
    /// Convenience for creating a closure that accepts a schema creator
    /// for the supplied model type on this schema executor.
    public static func create<Model>(_ model: Model.Type, on conn: Connection, closure: @escaping (SchemaCreator<Model>) throws -> ()) -> Future<Void>
        where Model.Database == Self
    {
        let creator = SchemaCreator(Model.self)
        return Future.flatMap(on: conn) {
            try closure(creator)
            return self.schemaExecute(creator.schema, on: conn)
        }
    }

    /// Convenience for creating a closure that accepts a schema updater
    /// for the supplied model type on this schema executor.
    public static func update<Model>(_ model: Model.Type, on conn: Connection, closure: @escaping (SchemaUpdater<Model>) throws -> ()) -> Future<Void>
        where Model.Database == Self
    {
        let updater = SchemaUpdater(Model.self)
        return Future.flatMap(on: conn) {
            try closure(updater)
            return self.schemaExecute(updater.schema, on: conn)
        }
    }

    /// Convenience for deleting the schema for the supplied model type.
    public static func delete<Model>(_ model: Model.Type, on conn: Connection) -> Future<Void>
        where Model: Fluent.Model, Model.Database == Self
    {
        return schemaExecute(.init(statement: .drop, table: Model.entity), on: conn)
    }
}

extension SchemaBuilder {
    public func customSQL(_ closure: (inout DataDefinitionQuery) -> ()) -> Self {
        closure(&schema)
        return self
    }
}

extension QueryBuilder where Model.Database: SQLDatabase {
    public func customSQL(_ closure: (inout DataManipulationQuery) -> ()) -> Self {
        closure(&query)
        return self
    }
}


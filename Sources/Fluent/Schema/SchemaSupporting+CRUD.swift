extension SchemaSupporting {
    // MARK: Convenience
    
    /// Convenience for creating a closure that accepts a schema creator
    /// for the supplied model type on this schema executor.
    public static func create<Model>(_ model: Model.Type, on conn: Connection, closure: @escaping (SchemaCreator<Model>) throws -> ()) -> Future<Void>
        where Model.Database == Self
    {
        let creator = SchemaCreator(Model.self)
        return Future.flatMap(on: conn) {
            try closure(creator)
            return conn.fluentOperation {
                return self.schemaExecute(creator.schema, on: conn)
            }
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
            return conn.fluentOperation {
                return self.schemaExecute(updater.schema, on: conn)
            }
        }
    }
    
    /// Convenience for deleting the schema for the supplied model type.
    public static func delete<Model>(_ model: Model.Type, on conn: Connection) -> Future<Void>
        where Model: Fluent.Model, Model.Database == Self
    {
        return conn.fluentOperation {
            return schemaExecute(Model.Database.schemaCreate(Model.Database.schemaActionDelete, Model.entity), on: conn)
        }
    }
}

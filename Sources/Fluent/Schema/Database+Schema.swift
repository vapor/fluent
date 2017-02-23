extension Database {
    /// Modifies the schema of the database
    /// for the given entity.
    public func modify(_ entity: String, closure: (Schema.Modifier) throws -> ()) throws {
        let modifier = Schema.Modifier(entity)
        try closure(modifier)
        _ = try schema(modifier.schema)
    }

    /// Creates the schema of the database
    /// for the given entity.
    public func create(_ entity: String, closure: (Schema.Creator) throws -> ()) throws {
        let creator = Schema.Creator(entity)
        try closure(creator)
        _ = try schema(creator.schema)
    }

    /// Deletes the schema of the database
    /// for the given entity.
    public func delete(_ entity: String) throws {
        let schema = Schema.delete(entity: entity)
        _ = try self.schema(schema)
    }
}

extension Database {
    /// Creates the schema of the database
    /// for the given entity.
    public func create<E: Entity>(_ e: E.Type, closure: (Schema.Creator) throws -> ()) throws {
        if e.database == nil { e.database = self }

        let creator = Schema.Creator(e.entity)
        try closure(creator)
        _ = try schema(creator.schema)
    }

    /// Modifies the schema of the database
    /// for the given entity.
    public func modify<E: Entity>(_ e: E.Type, closure: (Schema.Modifier) throws -> ()) throws {
        if e.database == nil { e.database = self }

        let modifier = Schema.Modifier(e.entity)
        try closure(modifier)
        _ = try schema(modifier.schema)
    }

    /// Deletes the schema of the database
    /// for the given entity.
    public func delete<E: Entity>(_ e: E.Type) throws {
        if e.database == nil { e.database = self }

        let schema = Schema.delete(entity: e.entity)
        _ = try self.schema(schema)
    }
}

extension Database {
    /**
        Modifies the schema of the database
        for the given entity.
    */
    public func modify(_ entity: String, closure: (Schema.Modifier) throws -> ()) throws {
        let modifier = Schema.Modifier(entity)
        try closure(modifier)
        _ = try driver.schema(modifier.schema)
    }

    /**
        Creates the schema of the database
        for the given entity.
    */
    public func create(_ entity: String, closure: (Schema.Creator) throws -> ()) throws {
        let creator = Schema.Creator(entity)
        try closure(creator)
        _ = try driver.schema(creator.schema)
    }

    /**
        Deletes the schema of the database
        for the given entity.
    */
    public func delete(_ entity: String) throws {
        let schema = Schema.delete(entity: entity)
        _ = try driver.schema(schema)
    }
}

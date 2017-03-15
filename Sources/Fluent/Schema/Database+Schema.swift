extension Database {
    /// Creates the schema of the database
    /// for the given entity.
    public func create<E: Entity>(_ e: E.Type, closure: (Creator) throws -> ()) throws {
        if e.database == nil { e.database = self }

        let creator = Creator()

        // add timestamps
        if E.usesTimestamps {
            creator.date(E.createdAtKey)
            creator.date(E.updatedAtKey)
        }

        try closure(creator)

        let query = Query<E>(self)
        query.action = .schema(.create(creator.fields))
        try self.query(query)
    }

    /// Modifies the schema of the database
    /// for the given entity.
    public func modify<E: Entity>(_ e: E.Type, closure: (Modifier) throws -> ()) throws {
        if e.database == nil { e.database = self }

        let modifier = Modifier()
        try closure(modifier)

        let query = Query<E>(self)
        query.action = .schema(.modify(
            add: modifier.fields,
            remove: modifier.delete
        ))
        try self.query(query)
    }

    /// Deletes the schema of the database
    /// for the given entity.
    public func delete<E: Entity>(_ e: E.Type) throws {
        if e.database == nil { e.database = self }

        let query = Query<E>(self)
        query.action = .schema(.delete)
        try self.query(query)
    }
}

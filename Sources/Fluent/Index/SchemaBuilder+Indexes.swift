extension SchemaBuilder where Model.Database: IndexSupporting {
    /// Adds an index to the supplied field.
    public func addIndex<T>(to field: KeyPath<Model, T>, isUnique: Bool = false) throws {
        let index = try SchemaIndex<Model.Database>(fields: [field.makeQueryField()], isUnique: isUnique)
        schema.addIndexes.append(index)
    }

    /// Adds an index to the supplied fields.
    public func addIndex<T, U>(to fieldA: KeyPath<Model, T>, _ fieldB: KeyPath<Model, U>, isUnique: Bool = false) throws {
        let index = try SchemaIndex<Model.Database>(fields: [fieldA.makeQueryField(), fieldB.makeQueryField()], isUnique: isUnique)
        schema.addIndexes.append(index)
    }

    /// Removes an index from the supplied field.
    public func removeIndex<T>(from field: KeyPath<Model, T>) throws {
        let index = try SchemaIndex<Model.Database>(fields: [field.makeQueryField()], isUnique: false)
        schema.removeIndexes.append(index)
    }

    /// Removes an index from the supplied fields.
    public func removeIndex<T, U>(from fieldA: KeyPath<Model, T>, _ fieldB: KeyPath<Model, U>) throws {
        let index = try SchemaIndex<Model.Database>(fields: [fieldA.makeQueryField(), fieldB.makeQueryField()], isUnique: false)
        schema.removeIndexes.append(index)
    }
}

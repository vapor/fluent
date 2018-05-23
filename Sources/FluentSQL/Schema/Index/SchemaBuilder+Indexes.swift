extension SchemaBuilder {
    /// Adds a `SchemaIndex` to the supplied field.
    ///
    ///     builder.addIndex(to: \.username, isUnique: true)
    ///
    /// - parameters:
    ///     - field: The field to index.
    ///     - isUnique: If `true`, this index will also force uniqueness.
    ///                 `false` by default.
    public func addIndex<T>(to field: KeyPath<Model, T>, isUnique: Bool = false) {
        let index = Model.Database.Schema.Index.fluentIndex(fields: [
            .keyPath(field)
        ], isUnique: isUnique)
        schema.fluentCreateIndexes.append(index)
    }

    /// Adds a single `SchemaIndex` to two fields.
    ///
    ///     builder.addIndex(to: \.username, \.email, isUnique: true)
    ///
    /// - parameters:
    ///     - fieldA: The first field to index.
    ///     - fieldB: The second field to index.
    ///     - isUnique: If `true`, this index will also force uniqueness.
    ///                 `false` by default.
    public func addIndex<T, U>(to fieldA: KeyPath<Model, T>, _ fieldB: KeyPath<Model, U>, isUnique: Bool = false) {
        let index = Model.Database.Schema.Index.fluentIndex(fields: [
            .keyPath(fieldA),
            .keyPath(fieldB)
        ], isUnique: isUnique)
        schema.fluentCreateIndexes.append(index)
    }

    /// Removes a `SchemaIndex` from a field.
    ///
    ///     builder.removeIndex(from: \.username)
    ///
    /// - parameters:
    ///     - field: The field to un-index.
    public func removeIndex<T>(from field: KeyPath<Model, T>) {
        let index = Model.Database.Schema.Index.fluentIndex(fields: [
            .keyPath(field)
        ], isUnique: false)
        schema.fluentDeleteIndexes.append(index)
    }

    /// Removes a single `SchemaIndex` from two fields.
    ///
    ///     builder.removeIndex(from: \.username, \.email)
    ///
    /// - parameters:
    ///     - fieldA: The first field to un-index.
    ///     - fieldB: The second field to un-index.
    public func removeIndex<T, U>(from fieldA: KeyPath<Model, T>, _ fieldB: KeyPath<Model, U>) {
        let index = Model.Database.Schema.Index.fluentIndex(fields: [
            .keyPath(fieldA),
            .keyPath(fieldB)
        ], isUnique: false)
        schema.fluentDeleteIndexes.append(index)
    }
}

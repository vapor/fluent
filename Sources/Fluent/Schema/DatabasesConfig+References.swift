extension DatabasesConfig {
    /// Disables references on the specified database.
    public mutating func enableReferences<D>(on db: DatabaseIdentifier<D>) where D: SchemaSupporting {
        appendConfigurationHandler(on: db) { D.enableReferences(on: $0) }
    }
    
    /// Enables references on the specified database.
    public mutating func disableReferences<D>(on db: DatabaseIdentifier<D>) where D: SchemaSupporting {
        appendConfigurationHandler(on: db) { D.disableReferences(on: $0) }
    }
}

extension DatabasesConfig {
    public mutating func enableReferebces<D>(on db: DatabaseIdentifier<D>) where D: SchemaSupporting {
        appendConfigurationHandler(on: db) { D.enableReferences(on: $0) }
    }
    
    public mutating func disableReferences<D>(on db: DatabaseIdentifier<D>) where D: SchemaSupporting {
        appendConfigurationHandler(on: db) { D.disableReferences(on: $0) }
    }
}

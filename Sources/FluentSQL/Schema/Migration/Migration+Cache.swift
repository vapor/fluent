extension MigrationConfig {
    /// Prepares the supplied `SchemaSupporting` database for use with `DatabaseKeyedCache`.
    public mutating func prepareCache<D>(for database: DatabaseIdentifier<D>) where D: SchemaSupporting {
        add(migration: CacheEntry<D>.self, database: database)
    }
}

/// Dynamically conform to `Migration` where the database is `SchemaSupporting`.
extension CacheEntry: Migration where Database: SchemaSupporting { }

extension MigrationConfig {
    /// Prepares the supplied `SQLDatabase` database for use with `DatabaseKeyedCache`.
    public mutating func prepareCache<D>(for database: DatabaseIdentifier<D>) where D: SQLSupporting {
        add(migration: CacheEntry<D>.self, database: database)
    }
}

/// Dynamically conform to `Migration` where the database is `SQLDatabase`.
extension CacheEntry: Migration where Database: SQLSupporting { }

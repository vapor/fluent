import Async

/// Prepares a `SchemaSupporting` database for use with `FluentCache`.
public final class FluentCacheMigration<D>: Migration where D: QuerySupporting, D: SchemaSupporting {
    /// See `Migration.Database`
    public typealias Database = D

    /// See `Migration.prepare(on:)`
    public static func prepare(on connection: D.Connection) -> Future<Void> {
        return Database.create(FluentCacheEntry<D>.self, on: connection) { builder in
            try builder.field(for: \.key)
            try builder.field(for: \.data)
        }
    }


    /// See `Migration.revert(on:)`
    public static func revert(on connection: D.Connection) -> Future<Void> {
        return Database.delete(FluentCacheEntry<D>.self, on: connection)
    }
}


extension MigrationConfig {
    /// Prepares the supplied `SchemaSupporting` database for `FluentCache` use.
    public mutating func prepareCache<D>(for database: DatabaseIdentifier<D>)
        where D: QuerySupporting, D: SchemaSupporting
    {
        self.add(migration: FluentCacheMigration<D>.self, database: database)
    }
}

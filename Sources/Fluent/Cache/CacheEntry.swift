/// Fluent model powering default implementation for `KeyedCacheSupporting` where self is `QuerySupporting`.
/// You can use this type to interact with the cache table if it has been configured.
///
/// See `DatabaseKeyedCache` for more information.
public final class CacheEntry<Database>: Model where Database: QuerySupporting {
    /// See `Model`.
    public static var name: String { return "fluentcache" }

    /// See `Model`.
    public typealias ID = String

    /// See `Model`
    public static var idKey: IDKey { return \.key }

    /// The cache entry's unique key.
    public var key: String?

    /// The cache entry's JSON encoded data.
    public var data: Data

    /// Creates a new `CacheEntry`.
    ///
    /// - parameters:
    ///     - key: The cache entry's unique key.
    ///     - data: The cache entry's JSON encoded data.
    public init(key: String, data: Data) {
        self.key = key
        self.data = data
    }
}

extension CacheEntry: CustomStringConvertible {
    /// See `CustomStringConvertible`.
    public var description: String {
        return (key ?? "nil") + ":" + data.description
    }
}

extension MigrationConfig {
    /// Prepares the supplied `SQLDatabase` database for use with `DatabaseKeyedCache`.
    public mutating func prepareCache<D>(for database: DatabaseIdentifier<D>) where D: SchemaSupporting & MigrationSupporting {
        add(migration: CacheEntry<D>.self, database: database)
    }
}

/// Dynamically conform to `Migration` where the database is `SQLDatabase`.
extension CacheEntry: AnyMigration, Migration where Database: SchemaSupporting & MigrationSupporting { }

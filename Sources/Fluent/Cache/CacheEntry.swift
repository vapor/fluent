extension MigrationConfig {
    /// Prepares the supplied `SchemaSupporting` database for use with `DatabaseKeyedCache`.
    public mutating func prepareCache<D>(for database: DatabaseIdentifier<D>)
        where D: QuerySupporting, D: SchemaSupporting
    {
        add(migration: CacheEntry<D>.self, database: database)
    }
}


/// Internal Fluent model powering `DatabaseKeyedCache`.
public final class CacheEntry<D>: Model
    where D: QuerySupporting
{
    /// See `Model`
    public static var name: String { return "fluentcache" }

    /// See `Model`
    public static var idKey: WritableKeyPath<CacheEntry<D>, String?> { return \.key }

    /// See `Model`
    public typealias Database = D

    /// The cache entry's unique key.
    public var key: String?

    /// The cache entry's JSON encoded data.
    public var data: Data

    /// Creates a new `CacheEntry`.
    public init(key: String, data: Data) {
        self.key = key
        self.data = data
    }
}

/// Dynamically conform to `Migration` where the database is `SchemaSupporting`.
extension CacheEntry: Migration where D: SchemaSupporting { }

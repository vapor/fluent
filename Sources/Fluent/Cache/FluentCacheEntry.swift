import Async
import Foundation

/// Internal Fluent model powering `FluentCache`.
public final class FluentCacheEntry<D>: Model
    where D: QuerySupporting
{
    /// See `Model.name`
    public static var name: String { return "fluentcache" }

    /// See `Model.idKey`
    public static var idKey: WritableKeyPath<FluentCacheEntry<D>, String?> { return \.key }

    /// See `Model.Database`
    public typealias Database = D

    /// The cache entry's unique key.
    public var key: String?

    /// The cache entry's JSON encoded data.
    public var data: Data

    /// Creates a new `CacheEntry`
    public init(key: String, data: Data) {
        self.key = key
        self.data = data
    }
}

extension FluentCacheEntry: Migration where D: SchemaSupporting { }


extension MigrationConfig {
    /// Prepares the supplied `SchemaSupporting` database for `FluentCache` use.
    public mutating func prepareCache<D>(for database: DatabaseIdentifier<D>)
        where D: QuerySupporting, D: SchemaSupporting
    {
        self.add(migration: FluentCacheEntry<D>.self, database: database)
    }
}

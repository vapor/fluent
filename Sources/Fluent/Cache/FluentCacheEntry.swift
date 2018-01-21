import Foundation

/// Internal Fluent model powering `FluentCache`.
internal final class FluentCacheEntry<D>: Model
    where D: QuerySupporting
{
    /// See `Model.name`
    internal static var name: String { return "fluentcache" }

    /// See `Model.idKey`
    internal static var idKey: IDKey { return \.key }

    /// See `Model.ID`
    internal typealias ID = String

    /// See `Model.Database`
    internal typealias Database = D

    /// The cache entry's unique key.
    internal var key: ID?

    /// The cache entry's JSON encoded data.
    internal var data: Data

    /// Creates a new `CacheEntry`
    internal init(key: String, data: Data) {
        self.key = key
        self.data = data
    }
}

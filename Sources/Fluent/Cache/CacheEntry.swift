/// Fluent model powering default implementation for `KeyedCacheSupporting` where self is `QuerySupporting`.
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

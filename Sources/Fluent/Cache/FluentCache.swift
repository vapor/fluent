import Async
import Foundation
import Service

/// A Fluent-based keyed cache implementation.
/// Requires a database prepared for querying `FluentCacheEntry` models.
public final class FluentCache<Database>: KeyedCache, Service
    where Database: QuerySupporting
{
    /// Used to request a connection for each get/set/remove
    private let pool: DatabaseConnectionPool<Database>

    /// Creates a new `FluentCache` with the supplied connection pool.
    public init(pool: DatabaseConnectionPool<Database>) {
        self.pool = pool
    }

    /// See `KeyedCache.get(_:forKey:)`
    public func get<D>(_ type: D.Type, forKey key: String) throws -> Future<D?> where D : Decodable {
        return pool.requestConnection().flatMap(to: D?.self) { conn in
            return FluentCacheEntry<Database>.find(key, on: conn).map(to: D?.self) { found in
                guard let entry = found else {
                    return nil
                }
                self.pool.releaseConnection(conn)
                return try JSONDecoder().decode(_DecodeWrapper<D>.self, from: entry.data).data
            }
        }
    }

    /// See `KeyedCache.set(_:forKey:)`
    public func set<E>(_ entity: E, forKey key: String) throws -> Future<Void> where E : Encodable {
        return pool.requestConnection().flatMap(to: Void.self) { conn in
            let data = try JSONEncoder().encode(_EncodeWrapper<E>(data: entity))
            return FluentCacheEntry<Database>(key: key, data: data).create(on: conn).map(to: Void.self) { entry in
                self.pool.releaseConnection(conn)
            }
        }
    }

    /// See `KeyedCache.remove(key:)`
    public func remove(_ key: String) throws -> Future<Void> {
        return pool.requestConnection().flatMap(to: Void.self) { conn in
            return FluentCacheEntry<Database>.query(on: conn).filter(\.key == key).delete().map(to: Void.self) {
                self.pool.releaseConnection(conn)
            }
        }
    }
}

/// Dictionary wrappers to prevent JSON failures from encoding top-level fragments.
fileprivate struct _EncodeWrapper<D>: Encodable where D: Encodable { let data: D }
fileprivate struct _DecodeWrapper<D>: Decodable where D: Decodable { let data: D }

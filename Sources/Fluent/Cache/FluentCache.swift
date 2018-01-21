import Async
import Foundation

public final class FluentCache<Database>: KeyedCache
    where Database: QuerySupporting
{
    private let pool: DatabaseConnectionPool<Database>

    public init(pool: DatabaseConnectionPool<Database>) {
        self.pool = pool
    }

    public func get<D>(_ type: D.Type, forKey key: String) throws -> Future<D?> where D : Decodable {
        return pool.requestConnection().flatMap(to: D?.self) { conn in
            return FluentCacheEntry<Database>.find(key, on: conn).map(to: D?.self) { found in
                guard let entry = found else {
                    return nil
                }
                self.pool.releaseConnection(conn)
                return try JSONDecoder().decode(D.self, from: entry.data)
            }
        }
    }

    public func set<E>(_ entity: E, forKey key: String) throws -> Future<Void> where E : Encodable {
        return pool.requestConnection().flatMap(to: Void.self) { conn in
            let data = try JSONEncoder().encode(entity)
            return FluentCacheEntry<Database>(key: key, data: data).save(on: conn).map(to: Void.self) { entry in
                self.pool.releaseConnection(conn)
            }
        }
    }

    public func remove(_ key: String) throws -> Future<Void> {
        return pool.requestConnection().flatMap(to: Void.self) { conn in
            return FluentCacheEntry<Database>.query(on: conn).filter(\.key == key).delete().map(to: Void.self) {
                self.pool.releaseConnection(conn)
            }
        }
    }


}


public final class FluentCacheEntry<D>: Model
    where D: QuerySupporting
{
    public static var idKey: IDKey { return \.key }
    public typealias ID = String
    public typealias Database = D
    public var key: ID?
    public var data: Data
    public init(key: String, data: Data) {
        self.key = key
        self.data = data
    }
}

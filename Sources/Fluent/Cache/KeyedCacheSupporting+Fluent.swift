/// Provides free `KeyedCacheSupporting` to `Database`s that conform to `QuerySupporting`.
extension KeyedCacheSupporting where Self: QuerySupporting {
    /// See `KeyedCacheSupporting`.
    public static func keyedCacheGet<D>(_ key: String, as decodable: D.Type, on conn: Self.Connection) -> Future<D?>
        where D: Decodable
    {
        return CacheEntry<Self>.find(key, on: conn).thenThrowing { found in
            guard let entry = found else {
                return nil
            }
            return try JSONDecoder().decode(Decode<D>.self, from: entry.data).data
        }

    }

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheSet<E>(_ key: String, to encodable: E, on conn: Self.Connection) throws -> Future<Void>
        where E: Encodable
    {
        let data = try JSONEncoder().encode(Encode<E>(data: encodable))
        return CacheEntry<Self>(key: key, data: data)
            .create(on: conn)
            .transform(to: ())
    }

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheRemove(_ key: String, on conn: Self.Connection) -> Future<Void>
    {
        return CacheEntry<Self>.query(on: conn)
            .filter(\.key == key)
            .delete()
    }
}

// MARK: Private

/// Dictionary wrappers to prevent JSON failures from encoding top-level fragments.
private struct Encode<E>: Encodable where E: Encodable { let data: E }
/// Dictionary wrappers to prevent JSON failures from encoding top-level fragments.
private struct Decode<D>: Decodable where D: Decodable { let data: D }

extension KeyedCacheSupporting where Self: QuerySupporting {
    /// See `KeyedCacheSupporting`.
    public static func keyedCacheGet<D>(_ key: String, as decodable: D.Type, on conn: Self.Connection) throws -> Future<D?>
        where D: Decodable
    {
        return try FluentCacheEntry<Self>.find(key, on: conn).thenThrowing { found in
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
        return FluentCacheEntry<Self>(key: key, data: data)
            .create(on: conn)
            .transform(to: ())
    }

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheRemove(_ key: String, on conn: Self.Connection) throws -> Future<Void>
    {
        return try FluentCacheEntry<Self>.query(on: conn)
            .filter(\.key, .equals, .data(key))
            .delete()
    }
}

// MARK: Private

/// Dictionary wrappers to prevent JSON failures from encoding top-level fragments.
private struct Encode<E>: Encodable where E: Encodable { let data: E }
private struct Decode<D>: Decodable where D: Decodable { let data: D }

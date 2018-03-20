final class QueryDataEncoder<Database> where Database: QuerySupporting {
    init(_ database: Database.Type) { }
    func encode<E>(_ data: E) throws -> [QueryField: Database.QueryData] where E: Encodable {
        let encoder = _QueryDataEncoder<Database>()
        try data.encode(to: encoder)
        return encoder.data
    }
}

/// MARK: Private

fileprivate final class _QueryDataEncoder<Database>: Encoder where Database: QuerySupporting {
    var codingPath: [CodingKey] { return [] }
    var userInfo: [CodingUserInfoKey: Any] { return [:] }
    var data: [QueryField: Database.QueryData]
    init() { self.data = [:] }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(_QueryDataKeyedEncoder<Key, Database>(encoder: self))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer { unsupported() }
    func singleValueContainer() -> SingleValueEncodingContainer { unsupported() }
}

private func unsupported() -> Never {
    fatalError("Fluent query data only supports a flat, keyed structure `[String: T]`.")
}

fileprivate struct _QueryDataKeyedEncoder<K, Database>: KeyedEncodingContainerProtocol
    where K: CodingKey, Database: QuerySupporting
{
    var codingPath: [CodingKey] { return [] }
    let encoder: _QueryDataEncoder<Database>
    init(encoder: _QueryDataEncoder<Database>) {
        self.encoder = encoder
    }

    mutating func _serialize<T>(_ value: T?, forKey key: K) throws {
        let field = QueryField(entity: nil, name: key.stringValue)
        encoder.data[field] = try Database.queryDataSerialize(data: value)
    }

    mutating func encodeNil(forKey key: K) throws { fatalError("`encodeNil` not supported. Use `encodeIfPresent` instead.") }
    mutating func encode<T>(_ value: T, forKey key: K) throws where T: Encodable { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: Bool?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: Int?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: Int16?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: Int32?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: Int64?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: UInt?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: UInt8?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: UInt16?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: UInt32?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: UInt64?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: Double?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: Float?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent(_ value: String?, forKey key: K) throws { try _serialize(value, forKey: key) }
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: K) throws where T: Encodable { try _serialize(value, forKey: key) }
    mutating func superEncoder() -> Encoder { return encoder }
    mutating func superEncoder(forKey key: K) -> Encoder { return encoder }
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey>
        where NestedKey : CodingKey { return encoder.container(keyedBy: NestedKey.self) }
    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer { return encoder.unkeyedContainer() }
}

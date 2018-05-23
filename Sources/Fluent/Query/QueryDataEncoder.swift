/// Internal encoder for converting `Encodable` models to `[Model.Database.Query.Field: Model.Database.Query.Data]`.
internal final class QueryDataEncoder<Model> where Model: Fluent.Model, Model.Database: QuerySupporting {
    init(_ type: Model.Type) { }
    
    func encode<E>(_ data: E) throws -> [Model.Database.Query.Field: Model.Database.Query.Data] where E: Encodable {
        let encoder = _QueryDataEncoder<Model>()
        try data.encode(to: encoder)
        return encoder.data
    }
}

/// MARK: Private

private final class _QueryDataEncoder<Model>: Encoder where Model: Fluent.Model, Model.Database: QuerySupporting{
    let codingPath: [CodingKey] = []
    let userInfo: [CodingUserInfoKey: Any] = [:]
    var data: [Model.Database.Query.Field: Model.Database.Query.Data]
    init() { self.data = [:] }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(_QueryDataKeyedEncoder<Key, Model>(encoder: self))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer { unsupported() }
    func singleValueContainer() -> SingleValueEncodingContainer { unsupported() }
}

private struct _QueryDataKeyedEncoder<K, Model>: KeyedEncodingContainerProtocol
    where K: CodingKey, Model: Fluent.Model, Model.Database: QuerySupporting
{
    let codingPath: [CodingKey] = []
    let encoder: _QueryDataEncoder<Model>
    init(encoder: _QueryDataEncoder<Model>) {
        self.encoder = encoder
    }

    mutating func _serialize<T>(_ value: T?, forKey key: K) throws where T: Encodable {
        encoder.data[.codingKey(key, rootType: Model.self, valueType: T.self)] = .fluentEncodable(value)
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

private func unsupported() -> Never {
    fatalError("Fluent query data only supports a flat, keyed structure `[String: T]`.")
}

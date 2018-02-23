internal final class RowEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol
{
    typealias Key = K
    var encoder: SQLiteRowEncoder
    var codingPath: [CodingKey] {
        get { return encoder.codingPath }
    }

    public init(encoder: SQLiteRowEncoder) {
        self.encoder = encoder
    }

    func encode(_ value: Bool, forKey key: K) throws {
        encoder.row[key.stringValue] = .integer(value ? 1 : 0)
    }

    func encode(_ value: Int, forKey key: K) throws {
        encoder.row[key.stringValue] = .integer(value)
    }

    func encode(_ value: Double, forKey key: K) throws {
        encoder.row[key.stringValue] = .float(value)
    }

    func encode(_ value: String, forKey key: K) throws {
        encoder.row[key.stringValue] = .text(value)
    }

    func encode<T>(_ value: T, forKey key: K) throws where T: Encodable {
        if let convertible = value as? SQLiteDataConvertible {
            encoder.row[key.stringValue] = try convertible.convertToSQLiteData()
        } else {
            let d = SQLiteDataEncoder()
            try value.encode(to: d)
            encoder.row[key.stringValue] = d.data
        }
    }

    func encodeIfPresent<T>(_ value: T?, forKey key: K) throws where T : Encodable {
        /// Strange that this is required now.... it this a bug?
        if let value = value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }

    func encodeNil(forKey key: K) throws {
        encoder.row[key.stringValue] = .null
    }

    func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type, forKey key: K
    ) -> KeyedEncodingContainer<NestedKey> {
        fatalError("SQLite rows do not support nested dictionaries")
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError("SQLite rows do not support nested arrays")
    }

    func superEncoder() -> Encoder {
        return encoder
    }

    func superEncoder(forKey key: K) -> Encoder {
        return encoder
    }
}



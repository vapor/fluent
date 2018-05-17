/// Capable of executing a database query.
public protocol QuerySupporting: Database {
    // MARK: Types
    associatedtype Query: Fluent.Query
    associatedtype Output

    // MARK: Run
    
    /// Executes the supplied query on the database connection.
    /// The returned future will be completed when the query is complete.
    /// Results will be outputed through the query's output stream.
    static func execute(
        query: Query,
        into handler: @escaping (Output, Connection) throws -> (),
        on connection: Connection
    ) -> Future<Void>

    // MARK: Decode

    /// Decodes a decodable type `D` from this database's `EntityType`.
    static func queryDecode<D>(_ data: Output, entity: String, as decodable: D.Type) throws -> D
        where D: Decodable

    // MARK: Lifecycle

    /// Handle model events.
    static func modelEvent<M>(event: ModelEvent, model: M, on connection: Connection) -> Future<M>
        where M: Model, M.Database == Self
}

public struct FluentProperty {
    public var entity: String?
    public var path: [String]
    public var valueType: Any.Type
}

public protocol PropertySupporting {
    static func fluentProperty(_ property: FluentProperty) -> Self
}

extension PropertySupporting {
    public static func keyPath<R,V>(_ keyPath: KeyPath<R, V>) -> Self {
        return .keyPath(keyPath, rootType: R.self, valueType: V.self)
    }

    public static func keyPath(_ keyPath: AnyKeyPath, rootType: Any.Type, valueType: Any.Type) -> Self {
        guard let reflectable = rootType as? (AnyReflectable & AnyModel).Type else {
            fatalError("`\(rootType)` is not `Reflectable`.")
        }
        guard let property = try! reflectable.anyReflectProperty(valueType: valueType, keyPath: keyPath) else {
            fatalError("Could not reflect property `\(keyPath)`.")
        }
        return .fluentProperty(.init(entity: reflectable.entity, path: property.path, valueType: valueType))
    }

    public static func codingKey<K, T>(_ key: K, type: T.Type, entity: String) -> Self
        where K: CodingKey
    {
        return .fluentProperty(.init(entity: entity, path: [key.stringValue], valueType: T.self))
    }

    public static func reflected(_ property: ReflectedProperty, entity: String) -> Self {
        return .fluentProperty(.init(entity: entity, path: property.path, valueType: property.type))
    }
}

public protocol QueryKey {
    associatedtype Field
    static var fluentAll: Self { get }
    static func fluentAggregate(_ method: QueryAggregateMethod, field: Field?) -> Self
}

public protocol QueryData {
    static func fluentEncodable(_ encodable: Encodable) -> Self
}

public protocol QueryAction {
    static var fluentCreate: Self { get }
    static var fluentRead: Self { get }
    static var fluentUpdate: Self { get }
    static var fluentDelete: Self { get }
    var fluentIsCreate: Bool { get }
}

public protocol QueryField: PropertySupporting, Hashable { }

public protocol QueryFilterMethod {
    static var fluentEqual: Self { get }
    static var fluentNotEqual: Self { get }
    static var fluentGreaterThan: Self { get }
    static var fluentLessThan: Self { get }
    static var fluentGreaterThanOrEqual: Self { get }
    static var fluentLessThanOrEqual: Self { get }
    static var fluentInSubset: Self { get }
    static var fluentNotInSubset: Self { get }
}

public protocol QueryFilterRelation {
    static var fluentAnd: Self { get }
    static var fluentOr: Self { get }
}

public protocol QueryFilter {
    associatedtype Field

    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype Method: QueryFilterMethod

    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype Value: QueryFilterValue

    associatedtype Relation: QueryFilterRelation

    static func unit(_ field: Field, _ method: Method, _ value: Value) -> Self
    static func group(_ relation: Relation, _ filters: [Self]) -> Self
}

public protocol QueryFilterValue: PropertySupporting {
    static func fluentBind(_ count: Int) -> Self
    static var fluentNil: Self { get }
}

/// Model events.
public enum ModelEvent {
    case willCreate
    case didCreate
    case willUpdate
    case didUpdate
    case willRead
    case willDelete
}


final class QueryDataEncoder<Model> where Model: Fluent.Model, Model.Database: QuerySupporting {
    init(_ type: Model.Type) { }
    func encode<E>(_ data: E) throws -> [Model.Database.Query.Field: Model.Database.Query.Data] where E: Encodable {
        let encoder = _QueryDataEncoder<Model>()
        try data.encode(to: encoder)
        return encoder.data
    }
}

/// MARK: Private
fileprivate final class _QueryDataEncoder<Model>: Encoder where Model: Fluent.Model, Model.Database: QuerySupporting{
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

private func unsupported() -> Never {
    fatalError("Fluent query data only supports a flat, keyed structure `[String: T]`.")
}

fileprivate struct _QueryDataKeyedEncoder<K, Model>: KeyedEncodingContainerProtocol
    where K: CodingKey, Model: Fluent.Model, Model.Database: QuerySupporting
{
    let codingPath: [CodingKey] = []
    let encoder: _QueryDataEncoder<Model>
    init(encoder: _QueryDataEncoder<Model>) {
        self.encoder = encoder
    }

    mutating func _serialize<T>(_ value: T?, forKey key: K) throws where T: Encodable {
        encoder.data[.codingKey(key, type: T.self, entity: Model.entity)] = .fluentEncodable(value)
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

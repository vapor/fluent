/// Represents a field and its optional entity in a query.
/// This is used mostly for query filters.
public struct QueryField: Hashable {
    /// See `Hashable.hashValue`
    public var hashValue: Int {
        return (entity ?? "<nil>" + "." + name).hashValue
    }

    /// See `Equatable.==`
    public static func ==(lhs: QueryField, rhs: QueryField) -> Bool {
        return lhs.name == rhs.name && lhs.entity == rhs.entity
    }

    /// The entity for this field.
    /// If the entity is nil, the query's default entity will be used.
    public var entity: String?

    /// The name of the field.
    public var name: String

    /// Create a new query field.
    public init(entity: String? = nil, name: String) {
        self.entity = entity
        self.name = name
    }
}

extension QueryField: CustomStringConvertible {
    /// See `CustomStringConvertible.description`
    public var description: String {
        return (entity ?? "<nil>") + "." + name
    }
}

extension QueryField: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral.init(stringLiteral:)`
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}

extension Dictionary where Key == QueryField {
    /// Accesses the _first_ value from this dictionary with a matching field name.
    public func firstValue(forField fieldName: String) -> Value? {
        for (field, value) in self {
            if field.name == fieldName {
                return value
            }
        }
        return nil
    }

    /// Access a `Value` from this dictionary keyed by `QueryField`s
    /// using a field (column) name and entity (table) name.
    public func value(forEntity entity: String, atField field: String) -> Value? {
        return self[QueryField(entity: entity, name: field)]
    }

    /// Removes all values that have non-matching entities.
    /// note: `QueryField`s with `nil` entities will still be included.
    public func onlyValues(forEntity entity: String) -> [QueryField: Value] {
        var result: [QueryField: Value] = [:]
        for (field, value) in self {
            if field.entity == nil || field.entity == entity {
                result[field] = value
            }
        }
        return result
    }
}

/// Conform key path's where the root is a model.
/// FIXME: conditional conformance
extension KeyPath where Root: Model {
    /// See QueryFieldRepresentable.makeQueryField()
    public func makeQueryField() throws -> QueryField {
        guard let key = try Root.reflectProperty(forKey: self) else {
            throw FluentError(identifier: "reflectProperty", reason: "No property reflected for \(self)", source: .capture())
        }
        return QueryField(entity: Root.entity, name: key.path.first ?? "")
    }
}

/// Allow models to easily generate query fields statically.
extension Model {
    /// Generates a query field with the supplied name for this model.
    ///
    /// You can use this method to create static variables on your model
    /// for easier access without having to repeat strings.
    ///
    ///     extension User: Model {
    ///         static let nameField = User.field("name")
    ///     }
    ///
    public static func field(_ name: String) -> QueryField {
        return QueryField(entity: Self.entity, name: name)
    }
}

// MARK: Coding key

/// Allow query fields to be used as coding keys.
extension QueryField: CodingKey {
    /// See CodingKey.stringValue
    public var stringValue: String {
        return name
    }

    /// See CodingKey.intValue
    public var intValue: Int? {
        return nil
    }

    /// See CodingKey.init(stringValue:)
    public init?(stringValue: String) {
        self.init(name: stringValue)
    }

    /// See CodingKey.init(intValue:)
    public init?(intValue: Int) {
        return nil
    }
}

extension Model {
    /// Creates a query field decoding container for this model.
    public static func decodingContainer(for decoder: Decoder) throws -> QueryFieldDecodingContainer<Self> {
        let container = try decoder.container(keyedBy: QueryField.self)
        return QueryFieldDecodingContainer(container: container)
    }

    /// Creates a query field encoding container for this model.
    public func encodingContainer(for encoder: Encoder) -> QueryFieldEncodingContainer<Self> {
        let container = encoder.container(keyedBy: QueryField.self)
        return QueryFieldEncodingContainer(container: container, model: self)
    }
}

/// A container for decoding model key paths.
public struct QueryFieldDecodingContainer<Model> where Model: Fluent.Model {
    /// The underlying container.
    public var container: KeyedDecodingContainer<QueryField>
    
    /// Decodes a model key path to a type.
    public func decode<T: Decodable>(key: KeyPath<Model, T>) throws -> T {
        let field = try key.makeQueryField()
        return try container.decode(T.self, forKey: field)
    }
}

/// A container for encoding model key paths.
public struct QueryFieldEncodingContainer<Model: Fluent.Model> {
    /// The underlying container.
    public var container: KeyedEncodingContainer<QueryField>

    /// The model being encoded.
    public var model: Model

    /// Encodes a model key path to the encoder.
    public mutating func encode<T: Encodable>(key: KeyPath<Model, T>) throws {
        let field = try key.makeQueryField()
        let value: T = model[keyPath: key]
        try container.encode(value, forKey: field)
    }
}

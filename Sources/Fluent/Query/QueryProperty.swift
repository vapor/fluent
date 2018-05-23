/// Capable of being created from a `QueryProperty` struct.
public protocol PropertySupporting {
    /// Creates an instance of self from a `QueryProperty`.
    static func fluentProperty(_ property: QueryProperty) -> Self
}

/// Represents a query property, potentially nested.
public struct QueryProperty {
    /// String path to the property.
    public var path: [String]

    /// The property's root type.
    public var rootType: Any.Type

    /// The property's value type.
    public var valueType: Any.Type
}

extension PropertySupporting {
    /// Creates self from a generic `KeyPath`.
    public static func keyPath<R,V>(_ keyPath: KeyPath<R, V>) -> Self {
        return .keyPath(any:keyPath, rootType: R.self, valueType: V.self)
    }

    /// Creates self from a type-erased `AnyKeyPath`.
    public static func keyPath(any keyPath: AnyKeyPath, rootType: Any.Type, valueType: Any.Type) -> Self {
        guard let reflectable = rootType as? AnyReflectable.Type else {
            fatalError("`\(rootType)` is not `Reflectable`.")
        }
        guard let property = try! reflectable.anyReflectProperty(valueType: valueType, keyPath: keyPath) else {
            fatalError("Could not reflect property `\(keyPath)`.")
        }
        return .fluentProperty(.init(path: property.path, rootType: rootType, valueType: valueType))
    }

    /// Creates self from a `CodingKey`.
    public static func codingKey(_ key: CodingKey, rootType: Any.Type, valueType: Any.Type) -> Self {
        return .fluentProperty(.init(path: [key.stringValue], rootType: rootType, valueType: valueType))
    }

    /// Creates self from a `ReflectedProperty`.
    public static func reflected(_ property: ReflectedProperty, rootType: Any.Type) -> Self {
        return .fluentProperty(.init(path: property.path, rootType: rootType, valueType: property.type))
    }
}

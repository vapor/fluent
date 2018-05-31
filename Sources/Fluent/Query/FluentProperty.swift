/// Represents a query property, potentially nested.
public struct FluentProperty {
    /// Creates self from a generic `KeyPath`.
    public static func keyPath<R,V>(_ keyPath: KeyPath<R, V>) -> FluentProperty {
        return .keyPath(any:keyPath, rootType: R.self, valueType: V.self)
    }

    /// Creates self from a type-erased `AnyKeyPath`.
    public static func keyPath(any keyPath: AnyKeyPath, rootType: Any.Type, valueType: Any.Type) -> FluentProperty {
        guard let reflectable = rootType as? AnyReflectable.Type else {
            fatalError("`\(rootType)` is not `Reflectable`.")
        }
        guard let property = try! reflectable.anyReflectProperty(valueType: valueType, keyPath: keyPath) else {
            fatalError("Could not reflect property `\(keyPath)`.")
        }
        return .init(path: property.path, rootType: rootType, valueType: valueType)
    }

    /// Creates self from a `CodingKey`.
    public static func codingKey(_ key: CodingKey, rootType: Any.Type, valueType: Any.Type) -> FluentProperty {
        return .init(path: [key.stringValue], rootType: rootType, valueType: valueType)
    }

    /// Creates self from a `ReflectedProperty`.
    public static func reflected(_ property: ReflectedProperty, rootType: Any.Type) -> FluentProperty {
        return .init(path: property.path, rootType: rootType, valueType: property.type)
    }

    /// String path to the property.
    public var path: [String]

    /// The property's root type.
    public var rootType: Any.Type

    /// The property's value type.
    public var valueType: Any.Type
}

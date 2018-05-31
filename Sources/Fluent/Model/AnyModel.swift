/// Type-erased model. See `Model`.
public protocol AnyModel: Codable {
    /// This model's unique name. By default, this property is set to a `String` describing the type.
    /// Override this property to update the model's readable name for all of Fluent.
    static var name: String { get }

    /// This model's collection/table name. Defaults to the model's `name` property.
    /// Override this property to change the model's table / collection name for all of Fluent.
    static var entity: String { get }
}

// MARK: Optional

extension AnyModel {
    /// See `AnyModel`.
    public static var name: String {
        return String(describing: Self.self)
    }

    /// See `AnyModel`.
    public static var entity: String {
        return name
    }
}

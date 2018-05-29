/// Type-erased model. See `Model`.
public protocol AnyModel: Codable {
    /// This model's unique name. Lowercased type name by default.
    static var name: String { get }

    /// This model's collection/table name. `name + "s"` by default.
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

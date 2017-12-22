import Foundation

/// Supported model identifier types.
public enum IDType {
    /// The identifier property on the model
    /// should always be `nil` when saving a new model.
    /// The database driver is expected to generate an
    /// autoincremented identifier based on previous
    /// identifiers that exist in the database.
    case driver

    /// The identifier property on the model should
    /// always be `nil` when saving a new model.
    /// The `FluentGeneratableID.generate()` will be used
    /// to generate a new identifier for new items.
    case fluent

    /// The identifier property on the model should
    /// always be set when saving a new model.
    case user
}

/// A Fluent generatable ID type.
public protocol FluentGeneratableID {
    /// Generates a new ID.
    static func generate() -> Self
}

extension UUID: FluentGeneratableID {
    /// FluentGeneratableID.generate
    public static func generate() -> UUID { return .init() }
}

import Async

/// Defines database types that support references
public protocol ReferenceSupporting: SchemaSupporting {
    /// Enables references errors.
    static func enableReferences(on connection: Connection) -> Future<Void>

    /// Disables reference errors.
    static func disableReferences(on connection: Connection) -> Future<Void>
}

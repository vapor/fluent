/// Defines database types that support references
public protocol ReferenceSupporting: SchemaSupporting {
    /// Enables references errors.
    static func enableReferences(on conn: Connection) -> Future<Void>

    /// Disables reference errors.
    static func disableReferences(on conn: Connection) -> Future<Void>
}

/// Types supported for representing
/// an entity's identifier.
public enum IdentifierType {
    case int
    case uuid
    /// For string IDs, provide a closure to be called for new IDs
    case string((() throws -> Identifier?))
    /// For custom IDs, provide the type to be stored in the database and a closure to be called for new IDs
    case custom(String, (() throws -> Identifier?))
}

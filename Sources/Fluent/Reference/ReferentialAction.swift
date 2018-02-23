/// Supported referential actions.
public enum ReferentialAction {
    /// Prevent changes to the database that will affect this reference.
    case prevent
    /// If this reference is changed, nullify the relation.
    /// Note: Requires optional field.
    case nullify
    /// If this reference is changed, update any dependents.
    case update

    /// The default `ReferentialAction`
    public static let `default`: ReferentialAction = .prevent
}

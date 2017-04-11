/// Modifies a schema. A subclass of Creator.
/// Can modify or delete fields.
public final class Modifier: Builder {
    /// The fields to be created
    public var fields: [RawOr<Field>]
    
    /// The foreign keys to be created
    public var foreignKeys: [RawOr<ForeignKey>]
    
    /// The fields to be deleted
    public var deleteFields: [RawOr<Field>]
    
    /// The foreign keys to be deleted
    public var deleteForeignKeys: [RawOr<ForeignKey>]

    /// Creators a new modifier
    public init() {
        fields = []
        foreignKeys = []
        deleteFields = []
        deleteForeignKeys = []
    }

    /// Delete a field with the given name
    public func delete(_ name: String) {
        let field = Field(
            name: name,
            type: .custom(type: "delete")
        )
        deleteFields.append(.some(field))
    }

    /// Delete a field with the given name
    public func delete(raw: String) {
        deleteFields.append(.raw(raw, []))
    }
}

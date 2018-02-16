/// A reference / foreign key is a field (or collection of fields) in one table
/// that uniquely identifies a row of another table or the same table.
public struct SchemaReference<Database> where Database: ReferenceSupporting & SchemaSupporting {
    /// The base field.
    public let base: QueryField

    /// The field this base field references.
    /// Note: this is a `QueryField` because we have limited info.
    /// we assume it is the same type as the base field.
    public let referenced: QueryField

    /// The action to take if this reference is modified.
    public let actions: ReferentialActions

    /// Creates a new SchemaReference
    public init(
        base: QueryField,
        referenced: QueryField,
        actions: ReferentialActions
    ) {
        self.base = base
        self.referenced = referenced
        self.actions = actions
    }

    /// Convenience init w/ schema field
    public init(base: SchemaField<Database>, referenced: QueryField, actions: ReferentialActions) {
        self.base = QueryField(entity: nil, name: base.name)
        self.referenced = referenced
        self.actions = actions
    }
}

extension DatabaseSchema where Database: ReferenceSupporting {
    /// Field to field references for this database schema.
    public var addReferences: [SchemaReference<Database>] {
        get { return extend["add-references"] as? [SchemaReference<Database>] ?? [] }
        set { extend["add-references"] = newValue }
    }

    /// Field to field references for this database schema.
    public var removeReferences: [SchemaReference<Database>] {
        get { return extend["remove-references"] as? [SchemaReference<Database>] ?? [] }
        set { extend["remove-references"] = newValue }
    }
}

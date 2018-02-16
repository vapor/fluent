/// An index on fields on the schema.
///
/// Indexes can apply to one or more fields and may increase
/// the performance of database fetches when filtering on the fields.
///
/// If the index is specified to be unique, the database engine is expected
/// to prevent creation of data where it already exists.
public struct SchemaIndex<Database> where Database: IndexSupporting & SchemaSupporting {
    /// The indexed fields.
    public let fields: [QueryField]

    /// If true, this index will also force uniqueness.
    public let isUnique: Bool

    /// Creates a new `SchemaIndex`
    public init(fields: [QueryField], isUnique: Bool) {
        assert(fields.count >= 1) // at least one field required
        self.fields = fields
        self.isUnique = isUnique
    }
}

extension DatabaseSchema where Database: IndexSupporting {
    /// Field indexes that should be added for this schema.
    public var addIndexes: [SchemaIndex<Database>] {
        get { return extend["add-indexes"] as? [SchemaIndex<Database>] ?? [] }
        set { extend["add-indexes"] = newValue }
    }

    /// Field indexes that should be removed for this schema.
    public var removeIndexes: [SchemaIndex<Database>] {
        get { return extend["remove-indexes"] as? [SchemaIndex<Database>] ?? [] }
        set { extend["remove-indexes"] = newValue }
    }
}

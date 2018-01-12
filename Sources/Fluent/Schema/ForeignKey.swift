/// A foreign key is a field (or collection of fields) in one table
/// that uniquely identifies a row of another table or the same table.
public struct ForeignKey {
    public enum ReferentialAction: String {
        case noAction = "NO ACTION"
        case restrict = "RESTRICT"
        case setNull = "SET NULL"
        case setDefault = "SET DEFAULT"
        case cascade = "CASCADE"
    }

    /// The entity type of the local field
    public let entity: Entity.Type
    /// The name of the field to hold the reference
    public let field: String
    /// The name of the field being referenced
    public let foreignField: String
    /// The entity type of the foreign field being referenced
    public let foreignEntity: Entity.Type
    /// The unique identifying name of this foreign key
    public var name: String
    /// The foreign key referential action which triggers on update
    public var onUpdate: ReferentialAction
    /// The foreign key referential action which triggers on delete
    public var onDelete: ReferentialAction

    /// Creates a new ForeignKey
    public init(
        entity: Entity.Type,
        field: String,
        foreignField: String,
        foreignEntity: Entity.Type,
        name: String? = nil,
        onUpdate: ReferentialAction = .noAction,
        onDelete: ReferentialAction = .noAction
    ) {
        self.entity = entity
        self.field = field
        self.foreignField = foreignField
        self.foreignEntity = foreignEntity
        self.name = name ?? "_fluent_fk_\(entity.entity).\(field)-\(foreignEntity.entity).\(foreignField)"
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
}


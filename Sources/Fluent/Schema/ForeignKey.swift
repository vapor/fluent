/// A foreign key is a field (or collection of fields) in one table
/// that uniquely identifies a row of another table or the same table.
public struct ForeignKey {
    /// The entity type of the local field
    public let entity: Entity.Type
    /// The name of the field to hold the reference
    public let field: String
    /// The name of the field being referenced
    public let foreignField: String
    /// The entity type of the foreign field being referenced
    public let foreignEntity: Entity.Type
    
    public var name: String {
        return "_fluent_fk_\(entity.entity).\(field)_\(foreignEntity.entity).\(foreignField)"
    }
    
    /// Creates a new ForeignKey
    public init(entity: Entity.Type, field: String, foreignField: String, foreignEntity: Entity.Type) {
        self.entity = entity
        self.field = field
        self.foreignField = foreignField
        self.foreignEntity = foreignEntity
    }
}

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
    /// The unique identifying name of this foreign key
    public var name: String
    
    /// Creates a new ForeignKey
    public init(
        entity: Entity.Type,
        field: String,
        foreignField: String,
        foreignEntity: Entity.Type,
        name: String? = nil
    ) {
        self.entity = entity
        self.field = field
        self.foreignField = foreignField
        self.foreignEntity = foreignEntity
        if  "_fluent_fk_\(entity.entity).\(field)-\(foreignEntity.entity).\(foreignField)".characters.count < 64{
		self.name = name ?? "_fluent_fk_\(entity.entity).\(field)-\(foreignEntity.entity).\(foreignField)"
	}else{
			
		/// we have "_fluent_fk_" + "." + "_" + "." = 14 characters
		/// so the reset must be less then 50 characters long
		/// 50 characters divided by 4 variables is 12 characters per variable

		let e1 = String("\(entity.entity)".characters.prefix(12))
		let e2 = String("\(foreignEntity.entity)".characters.prefix(12))
		let f1 = String("\(field)".characters.prefix(12))
		let f2 = String("\(foreignField)".characters.prefix(12))
	
		let timestamp = String(describing: Date().timeIntervalSince1970).suffix(12)

		self.name = name ?? "\(timestamp)_\(e1).\(f1)-\(e2).\(f2)"
	}
    }
}

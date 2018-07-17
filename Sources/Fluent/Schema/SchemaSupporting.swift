/// SQL database.
public protocol SchemaSupporting: QuerySupporting {
    /// Associated schema type.
    associatedtype Schema
    
    /// Associated schema action type.
    associatedtype SchemaAction
    
    /// Associated schema field type.
    associatedtype SchemaField
    
    /// Associated schema field data type.
    associatedtype SchemaFieldType
    
    /// Associated schema constraint type.
    associatedtype SchemaConstraint
    
    /// Associated reference action type.
    associatedtype SchemaReferenceAction
    
    /// Create schema action.
    static var schemaActionCreate: SchemaAction { get }
    
    /// Update schema action.
    static var schemaActionUpdate: SchemaAction { get }
    
    /// Delete schema action.
    static var schemaActionDelete: SchemaAction { get }
    
    /// Creates a schema.
    static func schemaCreate(_ action: SchemaAction, _ entity: String) -> Schema
    
    /// Creates a schema field.
    static func schemaField(for type: Any.Type, isIdentifier: Bool, _ field: QueryField) -> SchemaField
    
    /// Creates a schema field.
    static func schemaField(_ field: QueryField, _ type: SchemaFieldType) -> SchemaField
    
    /// Creates a field on the schema.
    static func schemaFieldCreate(_ field: SchemaField, to query: inout Schema)
    
    /// Deletes a field on the schema.
    static func schemaFieldDelete(_ field: QueryField, to query: inout Schema)
    
    /// Creates a reference constraint.
    static func schemaReference(from: QueryField, to: QueryField, onUpdate: SchemaReferenceAction?, onDelete: SchemaReferenceAction?) -> SchemaConstraint
    
    /// Creates a unique constraint.
    static func schemaUnique(on: [QueryField]) -> SchemaConstraint
    
    /// Creates a constraint on the schema.
    static func schemaConstraintCreate(_ constraint: SchemaConstraint, to query: inout Schema)
    
    /// Deletes a constraint on the schema.
    static func schemaConstraintDelete(_ constraint: SchemaConstraint, to query: inout Schema)
    
    /// Executes the supplied schema on the database connection.
    static func schemaExecute(_ schema: Schema, on conn: Connection) -> Future<Void>
    
    /// Enables references errors.
    static func enableReferences(on conn: Connection) -> Future<Void>
    
    /// Disables reference errors.
    static func disableReferences(on conn: Connection) -> Future<Void>
}

/// SQL database.
public protocol SchemaSupporting: QuerySupporting {
    associatedtype Schema
    
    associatedtype SchemaAction
    
    associatedtype SchemaField
    
    associatedtype SchemaFieldType
    
    associatedtype SchemaConstraint
    
    associatedtype SchemaReferenceAction
    
    static var schemaActionCreate: SchemaAction { get }
    
    static var schemaActionUpdate: SchemaAction { get }
    
    static var schemaActionDelete: SchemaAction { get }
    
    static func schemaCreate(_ action: SchemaAction, _ entity: String) -> Schema
    
    static func schemaField(for type: Any.Type, isIdentifier: Bool, _ field: QueryField) -> SchemaField
    
    static func schemaField(_ field: QueryField, _ type: SchemaFieldType) -> SchemaField
    
    static func schemaFieldCreate(_ field: SchemaField, to query: inout Schema)
    
    static func schemaFieldDelete(_ field: QueryField, to query: inout Schema)
    
    static func schemaReference(from: QueryField, to: QueryField, onUpdate: SchemaReferenceAction?, onDelete: SchemaReferenceAction?) -> SchemaConstraint
    
    static func schemaUnique(on: [QueryField]) -> SchemaConstraint
    
    static func schemaConstraintCreate(_ constraint: SchemaConstraint, to query: inout Schema)
    
    static func schemaConstraintDelete(_ constraint: SchemaConstraint, to query: inout Schema)
    
    /// Executes the supplied schema on the database connection.
    static func schemaExecute(_ schema: Schema, on conn: Connection) -> Future<Void>
    
    /// Enables references errors.
    static func enableReferences(on conn: Connection) -> Future<Void>
    
    /// Disables reference errors.
    static func disableReferences(on conn: Connection) -> Future<Void>
}

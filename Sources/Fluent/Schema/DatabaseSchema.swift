/// A query that can be sent to a Fluent database.
public struct DatabaseSchema<Database> where Database: SchemaSupporting {
    /// The entity to query
    public let entity: String

    /// The action to perform on the database
    public var action: SchemaAction

    /// The fields to add to this schema
    public var addFields: [SchemaField<Database>]

    /// The fields to be removed from this schema.
    public var removeFields: [String]

    /// Allows stored properties in extensions.
    public var extend: [String: Any]

    /// Create a new database query.
    public init(entity: String, action: SchemaAction) {
        self.entity = entity
        self.action = action
        self.addFields = []
        self.removeFields = []
        self.extend = [:]
    }
}

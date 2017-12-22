import Async

/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<M>: SchemaBuilder
    where M: Fluent.Model, M.Database: SchemaSupporting
{
    /// See SchemaBuilder.Model
    public typealias Model = M

    /// See SchemaBuilder.schema
    public var schema: DatabaseSchema<Model.Database>

    /// See SchemaBuilder.executor
    public let connection: Model.Database.Connection

    /// Create a new schema updater.
    public init(
        _ type: Model.Type = Model.self,
        on executor: Model.Database.Connection
    ) {
        schema = DatabaseSchema(entity: Model.entity)
        self.connection = executor
    }

    /// Deletes the field with the supplied name.
    public func delete(_ name: String) {
        schema.removeFields.append(name)
    }
}


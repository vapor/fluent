import Async

/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<Model>: SchemaBuilder<Model>
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{
    /// Deletes the field with the supplied name.
    public func delete(_ name: String) {
        schema.removeFields.append(name)
    }
}


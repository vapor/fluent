import Async

/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<Model>: SchemaBuilder<Model>
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{ }

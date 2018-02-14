import Async

/// Helps you create and execute a database schema.
public protocol SchemaBuilder: class {
    associatedtype Model: Fluent.Model where Model.Database: SchemaSupporting

    /// The schema being built.
    var schema: DatabaseSchema<Model.Database> { get set }

    /// Create a new schema creator.
    init(_ type: Model.Type)
}

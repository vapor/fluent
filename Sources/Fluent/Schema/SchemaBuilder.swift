import Async

/// Helps you create and execute a database schema.
public protocol SchemaBuilder: class {
    /// The associated model type.
    associatedtype Model: Fluent.Model
        where Self.Model.Database: SchemaSupporting

    /// The schema being built.
    var schema: DatabaseSchema<Model.Database> { get set }
}

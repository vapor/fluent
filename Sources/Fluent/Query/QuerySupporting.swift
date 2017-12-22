import Async

/// Capable of executing a database query.
public protocol QueryExecuting {
    /// Executes the supplied query on the database connection.
    /// The returned future will be completed when the query is complete.
    /// Results will be outputed through the query's output stream.
    func execute<I: InputStream, D: Decodable>(
        query: DatabaseQuery,
        into stream: I
    ) where I.Input == D

    /// The identifier property on the model
    /// should always be `nil` when saving a new model.
    /// The database driver is expected to generate an
    /// autoincremented identifier based on previous
    /// identifiers that exist in the database.
    func setID<M>(on model: M) throws where M: Model
}

public protocol QuerySupporting: Database where Self.Connection: QueryExecuting {
    /// Default schema field types Fluent must know
    /// how to make for migrations and tests.
    static func idType<T>(for type: T.Type) -> IDType where T: Fluent.ID
}

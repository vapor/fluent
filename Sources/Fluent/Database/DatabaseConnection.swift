import Async

/// Types conforming to this protocol can be used
/// as a Fluent database connection for executing queries.
public protocol DatabaseConnection: DatabaseConnectable {
    associatedtype Config

    /// This database's connection type.
    /// The connection should also know which
    /// type of database it belongs to.
    // associatedtype Database: Fluent.Database

    /// Closes the database connection when finished.
    func close()
}

/// Capable of being represented as a database connection
/// for the supplied identifier.
public protocol DatabaseConnectable {
    /// Create a database connection for the supplied dbid.
    func existingConnection<D>(to type: D.Type) -> D.Connection?
        where D: Database

    func connect<D>(to database: DatabaseIdentifier<D>) -> Future<D.Connection>
}

extension DatabaseConnection {
    /// Create a query for the specified model using this connection.
    public func query<M>(_ model: M.Type) -> QueryBuilder<M>
        where M.Database.Connection == Self
    {
        return QueryBuilder(M.self, on: Future(self))
    }
}

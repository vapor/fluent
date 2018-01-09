import Async

/// Types conforming to this protocol can be used
/// as a database connection for executing queries.
public protocol DatabaseConnection: DatabaseConnectable {
    associatedtype Config

    /// This database's connection type.
    /// The connection should also know which
    /// type of database it belongs to.
    // associatedtype Database: Fluent.Database

    /// Closes the database connection when finished.
    func close()
}

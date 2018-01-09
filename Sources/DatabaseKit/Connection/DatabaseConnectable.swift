import Async

/// Capable of being represented as a database connection
/// for the supplied identifier.
public protocol DatabaseConnectable {
    /// Create a database connection for the supplied dbid.
    ///
    /// If the database id is nil, any connection for this database
    /// type can be used.
    func connect<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection>
}

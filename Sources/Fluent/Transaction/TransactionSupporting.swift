/// Capable of executing a database transaction.
public protocol TransactionSupporting: Database {
    /// Executes the supplied transaction on the db connection.
    ///
    /// - parameters:
    ///     - transaction: Closure to run within a database transaction.
    ///                    Errors (throwing or returned by future) should cause a transaction rollback.
    ///     - conn: Database connection to use.
    /// - returns: A future containing the closure result.
    static func transactionExecute<T>(_ transaction:  @escaping (Connection) throws -> Future<T>, on conn: Connection) -> Future<T>
}

extension DatabaseConnectable {
    /// Performs a transaction on the referenced database.
    ///
    ///     conn.transaction(on: .mysql) { conn in
    ///         ...
    ///     }
    ///
    /// - parameters:
    ///     - db: `DatabaseIdentifier` to perform the transaction on.
    ///     - closure: Closure to perform within the database transaction.
    /// - returns: A future containing the closure result.
    public func transaction<Database, T>(on db: DatabaseIdentifier<Database>, _ closure: @escaping (Database.Connection) throws -> Future<T>) -> Future<T>
        where Database: TransactionSupporting
    {
        return databaseConnection(to: db).flatMap { conn in
            return Database.transactionExecute(closure, on: conn)
        }
    }
}

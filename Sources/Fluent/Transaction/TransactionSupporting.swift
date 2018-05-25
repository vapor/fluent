import Async

/// Capable of executing a database transaction.
public protocol TransactionSupporting: Database {
    /// Executes the supplied transaction on the db connection.
    static func transactionExecute<T>(_ transaction:  @escaping (Connection) throws -> Future<T>, on connection: Connection) -> Future<T>
}

extension DatabaseConnectable {
    public func transaction<Database, T>(on db: DatabaseIdentifier<Database>, _ closure: @escaping (Database.Connection) -> Future<T>) -> Future<T>
        where Database: TransactionSupporting
    {
        return databaseConnection(to: db).flatMap { conn in
            return Database.transactionExecute(closure, on: conn)
        }
    }
}

import Async

/// Capable of executing a database transaction.
public protocol TransactionSupporting: Database {
    /// Executes the supplied transaction on the db connection.
    static func execute(transaction: DatabaseTransaction<Self>, on connection: Connection) -> Future<Void>
}

extension TransactionSupporting {
    /// Convenience for executing a database transaction closure.
    public static func transaction(
        on connection: Connection,
        _ closure: @escaping DatabaseTransaction<Self>.Closure
    ) -> Future<Void> {
        let transaction = DatabaseTransaction<Self>(closure: closure)
        return execute(transaction: transaction, on: connection)
    }
}

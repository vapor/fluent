import Async

/// Capable of executing a database transaction.
public protocol TransactionSupporting: Database {
    /// Executes the supplied transaction on the db connection.
    static func execute<R>(transaction: DatabaseTransaction<Self, R>, on connection: Connection) -> Future<R>
}

extension TransactionSupporting {
    /// Convenience for executing a database transaction closure.
    public static func transaction<R>(
        on connection: Connection,
        _ closure: @escaping DatabaseTransaction<Self, R>.Closure
    ) -> Future<R> {
        let transaction = DatabaseTransaction<Self, R>(closure: closure)
        return execute(transaction: transaction, on: connection)
    }
}

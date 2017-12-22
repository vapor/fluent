import Async

/// Capable of executing a database transaction.
public protocol TransactionExecuting: DatabaseConnection {
    /// Executes the supplied transaction on the db connection.
    func execute(transaction: DatabaseTransaction<Self>) -> Future<Void>
}

public protocol TransactionSupporting: Database where Connection: TransactionExecuting { }

extension TransactionExecuting {
    /// Convenience for executing a database transaction closure.
    public func transaction(
        _ closure: @escaping DatabaseTransaction<Self>.Closure
    ) -> Future<Void> {
        let transaction = DatabaseTransaction(closure: closure)
        return execute(transaction: transaction)
    }
}

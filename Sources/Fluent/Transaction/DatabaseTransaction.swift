import Async

/// A database transaction. Work done inside the
/// transaction's closure will be rolled back if
/// any errors are thrown.
public struct DatabaseTransaction<D> where D: TransactionSupporting {
    /// Closure for performing the transaction.
    public typealias Closure = (D.Connection) throws -> Future<Void>

    /// Contains the transaction's work.
    public let closure: Closure

    /// Runs the transaction on a connection.
    public func run(on conn: D.Connection) -> Future<Void> {
        return Future.flatMap(on: conn) {
            return try self.closure(conn)
        }
    }
}

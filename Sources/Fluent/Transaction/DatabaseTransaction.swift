///// A database transaction. Work done inside the transaction's closure will be rolled back if
///// any errors are thrown.
//public struct DatabaseTransaction<Database, T> where Database: TransactionSupporting {
//    /// Contains the transaction's work.
//    public let closure: (Database.Connection) throws -> Future<T>
//
//    public init(closure: @escaping (Database.Connection) throws -> Future<T>) {
//        self.closure = closure
//    }
//
//    /// Runs the transaction on a connection.
//    public func run(on conn: Database.Connection) -> Future<T> {
//        do {
//            return try closure(conn)
//        } catch {
//            return conn.future(error: error)
//        }
//    }
//}

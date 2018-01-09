import Async
import DatabaseKit

extension DatabaseConnection {
    /// Create a query for the specified model using this connection.
    public func query<M>(_ model: M.Type) -> QueryBuilder<M>
        where M.Database.Connection == Self
    {
        return QueryBuilder(M.self, on: Future(self))
    }
}


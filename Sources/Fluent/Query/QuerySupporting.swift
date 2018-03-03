import Async

/// Capable of executing a database query.
public protocol QuerySupporting: Database {
    /// Executes the supplied query on the database connection.
    /// The returned future will be completed when the query is complete.
    /// Results will be outputed through the query's output stream.
    static func execute<D>(
        query: DatabaseQuery<Self>,
        into handler: @escaping (D, Connection) throws -> (),
        on connection: Connection
    ) -> Future<Void>
        where D: Decodable

    /// Handle model events.
    static func modelEvent<M>(event: ModelEvent, model: M, on connection: Connection) -> Future<M>
        where M: Model, M.Database == Self
}

/// Model events.
public enum ModelEvent {
    case willCreate
    case didCreate
    case willUpdate
    case didUpdate
    case willRead
    case willDelete
}

import Async

/// Capable of executing a database query.
public protocol QuerySupporting: Database {
    /// Executes the supplied query on the database connection.
    /// The returned future will be completed when the query is complete.
    /// Results will be outputed through the query's output stream.
    static func execute(
        query: DatabaseQuery<Self>,
        into handler: @escaping ([QueryField: QueryData], Connection) throws -> (),
        on connection: Connection
    ) -> Future<Void>

    /// Handle model events.
    static func modelEvent<M>(event: ModelEvent, model: M, on connection: Connection) -> Future<M>
        where M: Model, M.Database == Self

    /// This database's native data type.
    associatedtype QueryData: FluentData

    /// This database's convertible data type.
    /// This type is used in-place of the `QueryData` type wherever the user can input data.
    associatedtype QueryDataConvertible

    /// Serializes a native type to this db's `QueryDataConvertible`.
    static func queryDataSerialize<T>(data: T?) throws -> QueryData

    /// Parses this db's `QueryDataConvertible` into a native type.
    static func queryDataParse<T>(_ type: T.Type, from data: QueryData) throws -> T?

    /// This database's native filter types.
    associatedtype QueryFilter: Equatable
}

public protocol FluentData {
    var isNull: Bool { get }
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

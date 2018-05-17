/// Capable of executing a database query.
public protocol QuerySupporting: Database {
    // MARK: Types

    /// Discrete type that is passed to / from Fluent to the database.
    associatedtype EntityType

    /// Custom field type. Suppoed by `Query.Field`.
    associatedtype FieldType

    /// Custom value type. Supported by `Query.Value`.
    associatedtype DataType

    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype FilterMethodType

    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype FilterValueType

    // MARK: Run
    
    /// Executes the supplied query on the database connection.
    /// The returned future will be completed when the query is complete.
    /// Results will be outputed through the query's output stream.
    static func execute(
        query: Query<Self>,
        into handler: @escaping (EntityType, Connection) throws -> (),
        on connection: Connection
    ) -> Future<Void>

    // MARK: Codable

    /// Decodes a decodable type `D` from this database's `EntityType`.
    static func queryDecode<D>(_ data: EntityType, entity: String, as decodable: D.Type) throws -> D
        where D: Decodable

    // MARK: Lifecycle

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

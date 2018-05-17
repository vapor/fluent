import Async

/// Capable of executing a database query.
public protocol QuerySupporting: Database {
    // MARK: Execute

    associatedtype EntityType
    associatedtype FieldType
    associatedtype FilterType
    associatedtype ValueType
    
    /// Executes the supplied query on the database connection.
    /// The returned future will be completed when the query is complete.
    /// Results will be outputed through the query's output stream.
    static func execute(
        query: Query<Self>,
        into handler: @escaping (EntityType, Connection) throws -> (),
        on connection: Connection
    ) -> Future<Void>

    // MARK: Codable

    static func queryEncode<E>(_ encodable: E, entity: String) throws -> EntityType
        where E: Encodable

    static func queryDecode<D>(_ data: EntityType, entity: String, as decodable: D.Type) throws -> D
        where D: Decodable

    // MARK: Lifecycle

    /// Handle model events.
    static func modelEvent<M>(event: ModelEvent, model: M, on connection: Connection) -> Future<M>
    where M: Model, M.Database == Self
}


public protocol JoinSupporting: Database { }

//extension QuerySupporting {
//    public static func fieldType<M, T>(for keyPath: KeyPath<M, T>) throws -> FieldType where M: Model {
//        guard let property = try M.reflectProperty(forKey: keyPath) else {
//            throw FluentError(identifier: "reflectProperty", reason: "No property reflected for: \(keyPath)", source: .capture())
//        }
//        return try fieldType(for: property, entity: M.entity)
//    }
//}

/// Model events.
public enum ModelEvent {
    case willCreate
    case didCreate
    case willUpdate
    case didUpdate
    case willRead
    case willDelete
}

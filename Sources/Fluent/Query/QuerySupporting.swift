import Async

/// Capable of executing a database query.
public protocol QuerySupporting: Database {
    // MARK: Execute
    
    /// Executes the supplied query on the database connection.
    /// The returned future will be completed when the query is complete.
    /// Results will be outputed through the query's output stream.
    static func execute(
        query: DatabaseQuery<Self>,
        into handler: @escaping ([QueryField: QueryData], Connection) throws -> (),
        on connection: Connection
    ) -> Future<Void>

    // MARK: Codable

    static func queryEncode<E>(_ encodable: E, entity: String) throws -> [QueryField: QueryData]
        where E: Encodable

    static func queryDecode<D>(_ data: [QueryField: QueryData], entity: String, as decodable: D.Type) throws -> D
        where D: Decodable

    // MARK: Field

    /// This database's native data type.
    associatedtype QueryField: Hashable

    /// Creates a `QueryField` for the supplied `ReflectedProperty`.
    static func queryField(for reflectedProperty: ReflectedProperty, entity: String) throws -> QueryField

    // MARK: Data

    /// This database's native data type.
    associatedtype QueryData: FluentData

    /// Serializes a native type to this db's `QueryDataConvertible`.
    static func queryDataEncode<T>(_ data: T?) throws -> QueryData

    // MARK: Filter

    /// This database's native filter types.
    associatedtype QueryFilter: Equatable

    // MARK: Lifecycle

    /// Handle model events.
    static func modelEvent<M>(event: ModelEvent, model: M, on connection: Connection) -> Future<M>
    where M: Model, M.Database == Self
}

extension QuerySupporting {
    public static func queryField<M, T>(for keyPath: KeyPath<M, T>) throws -> QueryField where M: Model {
        guard let property = try M.reflectProperty(forKey: keyPath) else {
            throw FluentError(identifier: "reflectProperty", reason: "No property reflected for: \(keyPath)", source: .capture())
        }
        return try queryField(for: property, entity: M.entity)
    }
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

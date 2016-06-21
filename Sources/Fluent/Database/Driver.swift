/**
    A `Driver` execute queries
    and returns an array of results.
    It is responsible for interfacing
    with the data store powering Fluent.
*/
public protocol Driver {
    /**
        The string value for the 
        default identifier key.
     
        The `idKey` will be used when
        `Model.find(_:)` or other find
        by identifier methods are used.
    */
    var idKey: String { get }

    /**
        Executes a `Query` from and
        returns an array of results fetched,
        created, or updated by the action.
    */
    @discardableResult
    func query<T: Model>(_ query: Query<T>) throws -> [[String: Value]]

    /**
        Creates the `Schema` indicated
        by the `Builder`.
    */
    func schema(_ schema: Schema) throws
}

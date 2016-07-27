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
    func query<T: Entity>(_ query: Query<T>) throws -> Node

    /**
        Creates the `Schema` indicated
        by the `Builder`.
    */
    func schema(_ schema: Schema) throws

    /**
        Drivers that support raw querying
        accept string queries and parameterized values.

        This allows Fluent extensions to be written that
        can support custom querying behavior.
    */
    @discardableResult
    func raw(_ raw: String, _ values: [Node]) throws -> Node
}

extension Driver {
    @discardableResult
    public func raw(_ raw: String, _ values: [NodeRepresentable] = []) throws -> Node {
        let nodes = try values.map { try $0.makeNode() }
        return try self.raw(raw, nodes)
    }
}

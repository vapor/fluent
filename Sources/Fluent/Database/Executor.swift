/// An Executor is any entity that can execute
/// the queries for retreiving/sending data and
/// building databases that Fluent relies on.
///
/// Executors may include varying layers of
/// performance optimizations such as connection
/// and thread pooling.
///
/// The lowest level executor is usually a connection
/// while the highest level executor can have many
/// layers of abstraction on top of the connection
/// for performance and convenience.
public protocol Executor {
    /// Executes a `Query` from and
    /// returns an array of results fetched,
    /// created, or updated by the action.
    @discardableResult
    func query<T: Entity>(_ query: Query<T>) throws -> Node
    
    /// Creates the `Schema` indicated
    /// by the `Builder`.
    func schema(_ schema: Schema) throws
    
    /// Drivers that support raw querying
    /// accept string queries and parameterized values.
    ///
    /// This allows Fluent extensions to be written that
    /// can support custom querying behavior.
    @discardableResult
    func raw(_ raw: String, _ values: [Node]) throws -> Node
}

// MARK: Convenience

extension Executor {
    @discardableResult
    public func raw(_ raw: String, _ values: [NodeRepresentable] = []) throws -> Node {
        let nodes = try values.map { try $0.makeNode(in: rowContext) }
        return try self.raw(raw, nodes)
    }
}

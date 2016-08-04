
public class MemoryDriver: Driver {
    public var idKey: String = "id"
    
    internal(set) var memory: Memory = Memory()
    
    /**
     Executes a `Query` from and
     returns an array of results fetched,
     created, or updated by the action.
     */
    @discardableResult
    public func query<T: Entity>(_ query: Query<T>) throws -> Node {
        return .null
    }
    
    /**
     Creates the `Schema` indicated
     by the `Builder`.
     */
    public func schema(_ schema: Schema) throws {
        
    }
    
    /**
     Drivers that support raw querying
     accept string queries and parameterized values.
     
     This allows Fluent extensions to be written that
     can support custom querying behavior.
     */
    @discardableResult
    public func raw(_ raw: String, _ values: [Node]) throws -> Node {
        return .null
    }

}

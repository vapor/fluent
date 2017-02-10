/**
    A `Driver` execute queries
    and returns an array of results.
    It is responsible for interfacing
    with the data store powering Fluent.
*/
public protocol Driver: Executor {
    /**
        The string value for the 
        default identifier key.
     
        The `idKey` will be used when
        `Model.find(_:)` or other find
        by identifier methods are used.
    */
    var idKey: String { get }
    
    /**
        The default type for values stored against the identifier key.
     
        The `idType` will be accessed by those Entity implementations
        which do not themselves implement `Entity.idType`.
    */
    var idType: Schema.Field.KeyType { get }

    /**
        Creates a connection for executing 
        queries. This method is used to 
        automatically create a connection
        if any Executor methods are called on 
        the Driver.
    */
    func makeConnection() throws -> Connection
}

// MARK: Executor

extension Driver {
    @discardableResult
    public func query<T: Entity>(_ query: Query<T>) throws -> Node {
        return try makeConnection().query(query)
    }
    
    public func schema(_ schema: Schema) throws {
        return try makeConnection().schema(schema)
    }
    
    @discardableResult
    public func raw(_ raw: String, _ values: [Node]) throws -> Node {
        return try makeConnection().raw(raw, values)
    }
}


// MARK: Deprecated

enum DriverError: Error {
    case connectionsNotSupported(String)
}

extension Driver {
    public func makeConnection() throws -> Connection {
        throw DriverError.connectionsNotSupported("Please update your database driver package to be compatible with Fluent 1.4.")
    }
    
    public var idType: Schema.Field.KeyType {
        return .int
    }
}


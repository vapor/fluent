public final class MemoryDriver: Driver {
    public enum Error: Swift.Error {
        case unsupported
        case dataRequired
    }

    public var idKey: String = "id"

    public var idType: IdentifierType = .int

    var store: [String: Group]

    public init() {
        store = [:]
    }
    
    public func makeConnection() throws -> Connection {
        return MemoryConnection(driver: self)
    }
    
    func prepare(group name: String) -> Group {
        if let group = store[name] {
            return group
        }
        
        let group = Group()
        store[name] = group
        return group
    }
    
    func prepare(union: Join) -> Group {
        // create unioned table from two groups
        let local = prepare(group: union.local.entity)
        let foreign = prepare(group: union.foreign.entity)
        
        var unioned: [Node] = []
        
        // iterate over and merge table data
        // into one group
        for l in local.data {
            for f in foreign.data {
                if l[union.foreignKey] == f[union.localKey] {
                    var lf: [String: Node] = [:]
                    
                    if let of = f.nodeObject {
                        for (key, val) in of {
                            lf[key] = val
                        }
                    }
                    
                    if let ol = l.nodeObject {
                        for (key, val) in ol {
                            lf[key] = val
                        }
                    }
                    
                    unioned.append(Node.object(lf))
                }
            }
        }
        
        return Group(data: unioned)
    }
}

public final class MemoryConnection: Connection {
    public var closed: Bool

    public let driver: MemoryDriver
    
    public init(driver: MemoryDriver) {
        self.driver = driver
        closed = false
    }
    
    @discardableResult
    public func query<T: Entity>(_ query: Query<T>) throws -> Node {
        var group = driver.prepare(group: T.entity)

        switch query.action {
        case .create:
            guard let data = query.data else {
                throw MemoryDriver.Error.dataRequired
            }
            let i = group.create(data, idKey: T.idKey)

            return Node.number(.int(i))
        case .delete:
            group.delete(query.filters)
            return Node.array([])
        case .fetch:
            if let union = query.joins.first {
                group = driver.prepare(union: union)
            }
            
            let results = group.fetch(query.filters, query.sorts, query.limit)

            return Node.array(results)
        case .count:
            let count = group.fetch(query.filters, query.sorts).count
            
            return Node.number(.int(count))
        case .modify:
            guard let data = query.data else {
                throw MemoryDriver.Error.dataRequired
            }
            let results = group.modify(data, filters: query.filters)

            return Node.array(results)
        }
    }
    
    public func schema(_ schema: Schema) throws {
        // no schema changes necessary
        switch schema {
        case .delete(let entity):
            driver.store.removeValue(forKey: entity)
        default: break
        }
    }
    
    @discardableResult
    public func raw(_ raw: String, _ values: [Node]) throws -> Node {
        throw MemoryDriver.Error.unsupported
    }
}

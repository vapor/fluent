public final class MemoryDriver: Driver {
    public enum Error: Swift.Error {
        case unsupported
        case dataRequired
    }

    public var idKey: String = "id"
    var store: [String: Group]

    public init() {
        store = [:]
    }
    
    @discardableResult
    public func query<T: Entity>(_ query: Query<T>) throws -> Node {
        var group = prepare(group: query.entity)

        switch query.action {
        case .create:
            guard let data = query.data else {
                throw Error.dataRequired
            }
            let i = group.create(data, idKey: idKey)

            return Node.number(.int(i))
        case .delete:
            group.delete(query.filters)
            return Node.array([])
        case .fetch:
            if let union = query.unions.first {
                group = prepare(union: union)
            }
            
            let results = group.fetch(query.filters, query.sorts)

            return Node.array(results)
        case .modify:
            guard let data = query.data else {
                throw Error.dataRequired
            }
            let results = group.modify(data, filters: query.filters)

            return Node.array(results)
        }
    }
    
    public func schema(_ schema: Schema) throws {
        // no schema changes necessary
        switch schema {
        case .delete(let entity):
            store.removeValue(forKey: entity)
        default: break
        }
    }
    
    @discardableResult
    public func raw(_ raw: String, _ values: [Node]) throws -> Node {
        throw Error.unsupported
    }

    func prepare(group name: String) -> Group {
        if let group = store[name] {
            return group
        }

        let group = Group()
        store[name] = group
        return group
    }

    func prepare(union: Union) -> Group {
        // create unioned table from two groups
        let local = prepare(group: union.local.entity)
        let foreign = prepare(group: union.foreign.entity)

        var unioned: [Node] = []

        // iterate over and merge table data
        // into one group
        for l in local.data {
            for f in foreign.data {
                if l[union.localKey] == f[union.foreignKey] {
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

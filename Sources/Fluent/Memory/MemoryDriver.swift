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
        let group = prepare(group: query.entity)

        switch query.action {
        case .create:
            guard let data = query.data else {
                throw Error.dataRequired
            }
            let i = group.create(data, idKey: idKey)

            return Node.number(.int(i))
        case .delete:
            group.delete(query.filters)

            return .null
        case .fetch:
            let results = group.fetch(query.filters, query.sorts)

            return Node.array(results)
        case .count:
            let count = group.fetch(query.filters, query.sorts).count
            
            return Node.number(.int(count))
        case .modify:
            guard let data = query.data else {
                throw Error.dataRequired
            }
            let results = group.modify(data, filters: query.filters)

            return Node.array(results)
        }
    }
    
    public func schema(_ schema: Schema) throws {
        throw Error.unsupported
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
}

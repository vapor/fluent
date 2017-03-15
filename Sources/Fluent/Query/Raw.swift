public enum RawOr<Wrapped> {
    case raw(String, [Node])
    case some(Wrapped)
}

// MARK: Filter

extension QueryRepresentable {
    @discardableResult
    public func filter(
        raw string: String,
        _ values: [Node] = []
    ) throws -> Query<E> {
        let query = try makeQuery()
        query.filters.append(.raw(string, values))
        return query
    }

    @discardableResult
    public func filter(
        raw string: String,
        _ values: [NodeRepresentable]
    ) throws -> Query<E> {
        let query = try makeQuery()
        let values = try values.map { try $0.makeNode(in: query.context) }
        query.filters.append(.raw(string, values))
        return query
    }
}

// MARK: Join

extension QueryRepresentable {
    @discardableResult
    public func join(
        raw string: String
    ) throws -> Query<E> {
        let query = try makeQuery()
        query.joins.append(.raw(string, []))
        return query
    }
}

extension RawOr: CustomStringConvertible {
    public var description: String {
        switch self {
        case .raw(let string, let values):
            return "[raw] \(string) \(values)"
        case .some(let wrapped):
            return "\(wrapped)"
        }
    }
}

/**
    Defines a `Filter` that can be 
    added on fetch, delete, and update
    operations to limit the set of 
    data affected.
*/
public struct Filter {
    public enum Method {
        case compare(String, Comparison, Node)
        case subset(String, Scope, [Node])
    }

    public init(_ entity: Entity.Type, _ method: Method) {
        self.entity = entity
        self.method = method
    }

    public var entity: Entity.Type
    public var method: Method
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch method {
        case .compare(let field, let comparison, let value):
            return "(\(entity)) \(field) \(comparison) \(value)"
        case .subset(let field, let scope, let values):
            let valueDescriptions = values.map { $0.string ?? "" }
            return "(\(entity)) \(field) \(scope) \(valueDescriptions)"
        }
    }
}

extension QueryRepresentable {
    @discardableResult
    public func filter<T: Entity>(
        _ entity: T.Type,
        _ field: String,
        _ comparison: Filter.Comparison,
        _ value: NodeRepresentable
    ) throws -> Query<Self.T> {
        let query = try makeQuery()
        let filter = Filter(entity, .compare(field, comparison, try value.makeNode()))
        query.filters.append(filter)
        return query
    }

    @discardableResult
    public func filter<T: Entity>(
        _ entity: T.Type,
        _ field: String,
        _ scope: Filter.Scope,
        _ set: [NodeRepresentable]
        ) throws -> Query<Self.T> {
        let query = try makeQuery()
        let filter = Filter(T.self, .subset(field, scope, try set.map({ try $0.makeNode() })))
        query.filters.append(filter)
        return query
    }

    @discardableResult
    public func filter<T: Entity>(
        _ entity: T.Type,
        _ field: String,
        _ value: NodeRepresentable
    ) throws -> Query<Self.T> {
        return try makeQuery().filter(entity, field, .equals, value)
    }

    //MARK: Filter

    /**
        Adds a `.compare` filter to the query's
        filters.

        Used for filtering results based on how
        a result's value compares to the supplied value.
    */
    @discardableResult
    public func filter(
        _ field: String,
        _ comparison: Filter.Comparison,
        _ value: NodeRepresentable
    ) throws -> Query<Self.T> {
        return try makeQuery().filter(T.self, field, comparison, value)
    }

    /**
        Adds a `.subset` filter to the query's
        filters.

        Used for filtering results based on whether
        a result's value is or is not in a set.
    */
    @discardableResult
    public func filter(
        _ field: String,
        _ scope: Filter.Scope,
        _ set: [NodeRepresentable]
    ) throws -> Query<Self.T> {
        return try makeQuery().filter(T.self, field, scope, set)
    }


    /**
        Shortcut for creating a `.equals` filter.
    */
    @discardableResult
    public func filter(
        _ field: String,
        _ value: NodeRepresentable
    ) throws -> Query<Self.T> {
        return try makeQuery().filter(T.self, field, .equals, value)
    }


    @discardableResult
    public func filter(
        _ field: String,
        contains value: NodeRepresentable
    ) throws -> Query<Self.T> {
        return try filter(T.self, field, .contains(caseSensitive: false), value)
    }
}

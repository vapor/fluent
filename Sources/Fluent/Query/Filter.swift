/**
    Defines a `Filter` that can be 
    added on fetch, delete, and update
    operations to limit the set of 
    data affected.
*/
public enum Filter {
    case compare(String, Comparison, Node)
    case subset(String, Scope, [Node])
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compare(let field, let comparison, let value):
            return "\(field) \(comparison) \(value)"
        case .subset(let field, let scope, let values):
            let valueDescriptions = values.map { $0.string ?? "" }
            return "\(field) \(scope) \(valueDescriptions)"
        }
    }
}

extension Query {
    //MARK: Filter

    /**
        Adds a `.compare` filter to the query's
        filters.

        Used for filtering results based on how
        a result's value compares to the supplied value.
    */
    @discardableResult
    public func filter(_ field: String, _ comparison: Filter.Comparison, _ value: NodeRepresentable) -> Self {
        let filter = Filter.compare(field, comparison, value.makeNode())
        filters.append(filter)
        return self
    }

    /**
        Adds a `.subset` filter to the query's
        filters.

        Used for filtering results based on whether
        a result's value is or is not in a set.
    */
    @discardableResult
    public func filter(_ field: String, _ scope: Filter.Scope, _ set: [NodeRepresentable]) -> Self {
        let filter = Filter.subset(field, scope, set.map({ $0.makeNode() }))
        filters.append(filter)
        return self
    }


    /**
        Shortcut for creating a `.equals` filter.
    */
    @discardableResult
    public func filter(_ field: String, _ value: NodeRepresentable) -> Self {
        return filter(field, .equals, value)
    }

}

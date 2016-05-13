public enum Filter {
    case compare(String, Comparison, Filterable)
    case subset(String, Scope, [Filterable])
    indirect case group(Filter, Operation, Filter)
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compare(let field, let comparison, let value):
            return "\(field) \(comparison.rawValue) \(value.stringValue)"
        case .subset(let field, let scope, let values):
            return "\(field) \(scope.rawValue) \(values)"
        case let .group(left, operation, right):
            return "(\(left) \(operation.rawValue) \(right))"
        }
    }
}
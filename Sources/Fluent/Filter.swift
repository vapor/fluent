public enum Filter {
    indirect case not(Filter)
    case subset(String, Scope, [Filterable])
    case compare(String, Comparison, Filterable)
    indirect case group(Filter, Operation, Filter)
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .not(filter):
            return "!\(filter)"
        case let .subset(field, scope, values):
            return "\(field) \(scope.rawValue) \(values)"
        case let .group(left, operation, right):
            return "(\(left) \(operation.rawValue) \(right))"
        case let .compare(field, comparison, value):
            return "\(field) \(comparison.rawValue) \(value.stringValue)"
        }
    }
}

public prefix func !(filter: Filter) -> Filter {
    return .not(filter)
}
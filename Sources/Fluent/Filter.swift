public enum Filter {
    indirect case not(Filter)
    case compare(String, Comparison, Filterable)
    case subset(String, SubsetScope, [Filterable])
    indirect case group(Filter, Operation, Filter)
    case range(String, RangeScope, Filterable, Filterable)
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
        case let .range(field, range, value1, value2):
            return "\(field) \(range.rawValue) \(value1) and \(value2)"
        case let .compare(field, comparison, value):
            return "\(field) \(comparison.rawValue) \(value.stringValue)"
        }
    }
}

public prefix func !(filter: Filter) -> Filter {
    return .not(filter)
}

infix operator =~ { precedence 130 }
infix operator !~ { precedence 130 }
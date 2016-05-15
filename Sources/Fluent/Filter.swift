public protocol FilterProtocol: CustomStringConvertible {}

public indirect enum Filter<Value: Filterable> {
    case not(Filter)
    case compare(String, Comparison, Value)
    case subset(String, SubsetScope, [Value])
    case range(String, RangeScope, Value, Value)
    case group(FilterProtocol, Operation, FilterProtocol)
}

extension Filter: FilterProtocol {
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

public prefix func !<T: Filterable>(filter: Filter<T>) -> Filter<T> {
    return .not(filter)
}

infix operator =~ { precedence 130 }
infix operator !~ { precedence 130 }
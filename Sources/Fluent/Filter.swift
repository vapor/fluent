public indirect enum Filter {
    case not(Filter)
    case both(Filter, and: Filter)
    case either(Filter, or: Filter)
    case find(String, Scope)
    case compare(String, Comparison, Value)
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .not(filter):
            return "NOT(\(filter))"
        case let .both(left, and: right):
            return "(\(left)) AND (\(right))"
        case let .either(left, or: right):
            return "(\(left)) OR (\(right))"
        case let .find(field, scope):
            switch scope {
            case let .`in`(values):
                return "(`\(field)` IN \(values))"
            case let .between(low, and: high):
                return "(`\(field)` BETWEEN \(low) AND \(high))"
            }
        case let .compare(field, comparison, value):
            return "`\(field)` \(comparison.rawValue) \(value.string)"
        }
    }
}

public prefix func !(filter: Filter) -> Filter {
    return .not(filter)
}
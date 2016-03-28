public enum Filter {
    case Compare(String, Comparison, Value)
    case Subset(String, Scope, [Value])
    case Group(Operation, [Filter])
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Compare(let field, let comparison, let value):
            return "\(field) \(comparison) \(value.string)"
        case .Subset(let field, let scope, let values):
            let valueDescriptions = values.map { return $0.description }
            return "\(field) \(scope) \(valueDescriptions)"
        case .Group(let op, let filters):
            return "\(op.description) \(filters)"
        }
    }
}
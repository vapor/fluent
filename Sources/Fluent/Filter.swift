public enum Filter {
    case compare(String, Comparison, Value)
    case subset(String, Scope, [Value])
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compare(let field, let comparison, let value):
            return "\(field) \(comparison) \(value)"
        case .subset(let field, let scope, let values):
            let valueDescriptions = values.map { return $0.description }
            return "\(field) \(scope) \(valueDescriptions)"
        }
    }
}
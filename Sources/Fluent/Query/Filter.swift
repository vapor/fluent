/**
    Defines a `Filter` that can be 
    added on fetch, delete, and update
    operations to limit the set of 
    data affected.
*/
public enum Filter {
    case compare(String, Comparison, Value)
    case subset(String, Scope, [Value])
    case partial_compare(String, PartialComparison, String)
}

extension Filter: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compare(let field, let comparison, let value):
            return "\(field) \(comparison) \(value)"
        case .subset(let field, let scope, let values):
            let valueDescriptions = values.map { $0.description }
            return "\(field) \(scope) \(valueDescriptions)"
        case .partial_compare(let field, let partial, let value):
            let valueDescription: String
            switch partial {
            case .beginsWith:
                valueDescription = "\(value)%"
            case .endsWith:
                valueDescription = "%\(value)"
            case .contains:
                valueDescription = "%\(value)%"
            }
            return "\(field) LIKE '\(valueDescription)'"
        }
    }
}
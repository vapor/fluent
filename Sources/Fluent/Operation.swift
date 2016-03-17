extension Filter {
    public enum Operation {
        case And, Or
        
        
    }
}

extension Filter.Operation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .And:
            return "and"
        case .Or:
            return "or"
        }
    }
}
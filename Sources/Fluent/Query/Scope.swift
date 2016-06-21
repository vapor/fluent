extension Filter {
    /**
        Describes the methods for comparing
        a value to a set of values.
    */
    public enum Scope {
        case `in`, notIn
    }
}

extension Filter.Scope: CustomStringConvertible {
    public var description: String {
        return self == .in ? "in" : "not in"
    }
}

/// Temporarily not in SQL.swift file
extension Filter.Scope {
    /**
     Translates a scope to SQL.
     */
    var sql: String {
        switch self {
        case .in:
            return "IN"
        case .notIn:
            return "NOT IN"
        }
    }
}

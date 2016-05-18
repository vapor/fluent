public enum Action {
    case select
    case delete
    case insert
    case update
}

extension Action: CustomStringConvertible {
    public var description: String {
        switch self {
        case select:
            return "select"
        case delete:
            return "delete"
        case insert:
            return "insert"
        case update:
            return "update"
        }
    }
}
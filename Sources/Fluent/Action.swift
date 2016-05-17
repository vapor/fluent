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
            return "select * from"
        case delete:
            return "delete from"
        case insert:
            return "insert into"
        case update:
            return "update"
        }
    }
}
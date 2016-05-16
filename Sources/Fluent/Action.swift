public enum Action {
    case select(distinct: Bool)
    case delete
    case insert
    case update
    case count
    case maximum
    case minimum
    case average
    case sum
}

extension Action: CustomStringConvertible {
    public var description: String {
        switch self {
        case select(distinct: let distinct):
            if distinct {
                return "select distinct * from"
            }
            return "select * from"
        case delete:
            return "delete from"
        case insert:
            return "insert into"
        case update:
            return "update"
        case count:
            return "select count(*) from"
        case maximum:
            return "select max(*) from"
        case minimum:
            return "select min(*) from"
        case average:
            return "select avg(*) from"
        case sum:
            return "select sum(*) from"
        }
    }
}
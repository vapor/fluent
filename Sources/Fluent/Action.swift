public enum Action {
    case Select(Bool) // distinct
    case Delete
    case Insert
    case Update
    case Count
    case Maximum
    case Minimum
    case Average
    case Sum
}

extension Action: CustomStringConvertible {
    public var description: String {
        switch self {
        case Select(let distinct):
            if distinct {
                return "select distinct * from"
            }
            return "select * from"
        case Delete:
            return "delete from"
        case Insert:
            return "insert into"
        case Update:
            return "update"
        case Count:
            return "select count(*) from"
        case Maximum:
            return "select max(*) from"
        case Minimum:
            return "select min(*) from"
        case Average:
            return "select avg(*) from"
        case Sum:
            return "select sum(*) from"
        }
    }
}
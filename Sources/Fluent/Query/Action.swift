/// The types of actions that can be performed
/// on database entities, such as fetching, deleting,
/// creating, and updating.
public enum Action {
    case fetch
    case count
    case sum([String], Operator)
    case min([String], Operator)
    case max([String], Operator)
    case average([String], Operator)
    case delete
    case create
    case modify
    case schema(Schema)
}

public enum Operator: CustomStringConvertible {
    case add
    case subtract
    case multiply
    case divide
    case other(string: String)
    
    public var description: String {
        switch self {
        case .add: return "+"
        case .subtract: return "-"
        case .multiply: return "*"
        case .divide: return "/"
        case .other(let string): return string
        }
    }
}

public enum Schema {
    case create(
        fields: [RawOr<Field>],
        foreignKeys: [RawOr<ForeignKey>]
    )
    case modify(
        fields: [RawOr<Field>],
        foreignKeys: [RawOr<ForeignKey>],
        deleteFields: [RawOr<Field>],
        deleteForeignKeys: [RawOr<ForeignKey>]
    )
    case createIndex(RawOr<Index>)
    case deleteIndex(RawOr<Index>)
    case delete
}

extension Action: Equatable {
    public static func ==(lhs: Action, rhs: Action) -> Bool {
        switch (lhs, rhs) {
        case (.fetch, .fetch),
             (.count, .count),
             (.min, .min),
             (.max, .max),
             (.average, .average),
             (.delete, .delete),
             (.create, .create),
             (.modify, .modify):
            return true
        case (.schema(let a), .schema(let b)):
            return a == b
        default:
            return false
        }
    }
}

extension Schema: Equatable {
    public static func ==(lhs: Schema, rhs: Schema) -> Bool {
        switch (lhs, rhs) {
        case (.create(let af, let afk), .create(let bf, let bfk)):
            return af == bf && afk == bfk
        case (.modify(let aa, let ab, let ac, let ad), .modify(let ba, let bb, let bc, let bd)):
            return aa == ba && ab == bb && ac == bc && ad == bd
        case (.delete, .delete):
            return true
        case (.createIndex(let a), .createIndex(let b)):
            return a == b
        case (.deleteIndex(let a), .deleteIndex(let b)):
            return a == b
        default:
            return false
        }
    }
}

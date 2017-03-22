/// The types of actions that can be performed
/// on database entities, such as fetching, deleting,
/// creating, and updating.
public enum Action {
    case fetch
    case count
    case delete
    case create
    case modify
    case schema(Schema)
}

public enum Schema {
    case create([RawOr<Field>])
    case modify(add: [RawOr<Field>], remove: [RawOr<Field>])
    case delete
}

extension Action: Equatable {
    public static func ==(lhs: Action, rhs: Action) -> Bool {
        switch (lhs, rhs) {
        case (.fetch, .fetch),
             (.count, .count),
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
        case (.create(let a), .create(let b)):
            return a == b
        case (.modify(let addA, let removeA), .modify(let addB, let removeB)):
            return addA == addB && removeA == removeB
        case (.delete, .delete):
            return true
        default:
            return false
        }
    }
}

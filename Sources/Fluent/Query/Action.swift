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
    case create([Field])
    case modify(add: [Field], remove: [Field])
    case delete
}

extension Action: Equatable {
    public static func ==(lhs: Action, rhs: Action) -> Bool {
        switch lhs {
        case .fetch:
            switch rhs {
            case .fetch: return true
            default: return false
            }
        case .count:
            switch rhs {
            case .count: return true
            default: return false
            }
        case .delete:
            switch rhs {
            case .delete: return true
            default: return false
            }
        case .create:
            switch rhs {
            case .create: return true
            default: return false
            }
        case .modify:
            switch rhs {
            case .modify: return true
            default: return false
            }
        case .schema(let a):
            switch rhs {
            case .schema(let b): return a == b
            default: return false
            }

        }
    }
}

extension Schema: Equatable {
    public static func ==(lhs: Schema, rhs: Schema) -> Bool {
        switch lhs {
        case .create(let a):
            switch rhs {
            case .create(let b): return a == b
            default: return false
            }
        case .modify(let addA, let removeA):
            switch rhs {
            case .modify(let addB, let removeB):
                return addA == addB && removeA == removeB
            default: return false
            }
        case .delete:
            switch rhs {
            case .delete: return true
            default: return false
            }
        }
    }
}

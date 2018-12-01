public struct FluentQuery {
    public enum Action {
        case create
        case read
        case update
        case delete
    }

    public var action: Action
    public var entity: String
    public var filters: [FluentFilter]
    
    public init(entity: String) {
        self.action = .read
        self.entity = entity
        self.filters = []
    }
}

public struct FluentField {
    public var entity: String?
    public var path: [String]
    
    public init(entity: String? = nil, _ path: String...) {
        self.entity = entity
        self.path = path
    }
}

public enum FluentFilter {
    public enum Method {
        public enum Like {
            case prefix
            case suffix
            case any
        }
        case equal
        case notEqual
        case greaterThan
        case lessThan
        case greaterThanOrEqual
        case lessThanOrEqual
        case `in`
        case notIn
        case like(Like)
        case notLike(Like)
        case custom(Any)
    }
    
    public enum Relation {
        case and
        case or
        case custom(Any)
    }
    
    case basic(FluentField, Method, FluentValue)
    case group([FluentFilter], Relation)
    case custom(Any)
}

public enum FluentValue {
    case bind(Encodable)
    case array([FluentValue])
    case null
    case custom(Any)
}

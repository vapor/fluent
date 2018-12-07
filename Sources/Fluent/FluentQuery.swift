public struct FluentQuery {
    public enum Action {
        case create
        case read
        case update
        case delete
        case custom(Any)
    }
    
    public enum Field {
        case field(name: String, entity: String?)
        case custom(Any)
    }
    
    public enum Filter {
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
        
        case basic(Field, Method, Value)
        case group([Filter], Relation)
        case custom(Any)
    }
    
    public enum Value {
        case bind(Encodable)
        case array([Value])
        case null
        case custom(Any)
    }

    public var fields: [Field]
    public var action: Action
    public var entity: String
    public var filters: [Filter]
    
    public init(entity: String) {
        self.fields = []
        self.action = .read
        self.entity = entity
        self.filters = []
    }
}

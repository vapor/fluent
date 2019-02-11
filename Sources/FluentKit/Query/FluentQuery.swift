public struct FluentQuery {
    public enum Action {
        case create
        case read
        case update
        case delete
        case custom(Any)
    }
    
    public enum Field {
        case field(path: [String], entity: String?, alias: String?)
        case custom(Any)
    }
    
    public enum Filter {
        public enum Method {
            public static var equals: Method {
                return .equality(inverse: false)
            }
            
            /// LHS is equal to RHS
            case equality(inverse: Bool)
            
            /// LHS is greater than RHS
            case order(inverse: Bool, equality: Bool)
            
            /// LHS exists in RHS
            case subset(inverse: Bool)
            
            public enum Contains {
                case prefix
                case suffix
                case anywhere
            }
            /// RHS exists in LHS
            case contains(inverse: Bool, Contains)
            
            /// Custom method
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
        case dictionary([String: Value])
        case array([Value])
        case null
        case custom(Any)
    }
    
    public enum Join {
        case model(foreign: Field, local: Field)
        case custom(Any)
    }
    
    public var fields: [Field]
    public var action: Action
    public var entity: String
    public var filters: [Filter]
    public var input: [[Value]]
    public var joins: [Join]
    
    public init(entity: String) {
        self.fields = []
        self.action = .read
        self.entity = entity
        self.filters = []
        self.input = []
        self.joins = []
    }
}

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

public struct FluentFilter {
    public struct Method {
        public static var equal: Method {
            return .init(isInverse: false, operation: .equality)
        }
        
        public static var notEqual: Method {
            return .init(isInverse: true, operation: .equality)
        }
        
        public enum Operation {
            case equality
            case comparison(equality: Bool)
            case subset
            
            public enum Like {
                case any
                case prefix
                case suffix
            }
            case like(Like)
        }
        
        public var isInverse: Bool
        public var operation: Operation
    }
    
    public var field: FluentField
    public var method: Method
    public var value: FluentValue
    
    public init(field: FluentField, method: Method, value: FluentValue) {
        self.field = field
        self.method = method
        self.value = value
    }
}

public enum FluentValue {
    case encodable(Encodable)
    case null
}

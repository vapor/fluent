import Foundation

public struct FluentSchema {
    public enum Action {
        case create
        case update
        case delete
    }
    
    public enum DataType {
        static func bestFor(type: Any.Type) -> DataType {
            func id(_ type: Any.Type) -> ObjectIdentifier {
                return ObjectIdentifier(type)
            }
            
            switch id(type) {
            case id(String.self): return .string
            case id(Int.self), id(Int64.self): return .int64
            case id(UInt.self), id(UInt64.self): return .uint64
            case id(UUID.self): return .uuid
            case id(Date.self): return .datetime
            default: return .json
            }
        }
        
        case json
        
        public static var int: DataType {
            return .int64
        }
        case int8
        case int16
        case int32
        case int64
        
        public static var uint: DataType {
            return .uint64
        }
        case uint8
        case uint16
        case uint32
        case uint64
        
        
        case bool
        
        public struct Enum {
            var name: String
            var cases: [String]
        }
        case `enum`(Enum)
        case string
        
        case time
        case date
        case datetime
        
        case float
        case double
        case data
        case uuid
        case custom(Any)
    }
    
    public enum FieldConstraint {
        case required
        case identifier
        case custom(Any)
    }
    
    public enum FieldDefinition {
        case definition(name: FieldName, dataType: DataType, constraints: [FieldConstraint])
        case custom(Any)
    }
    
    public enum FieldName {
        case string(String)
        case custom(Any)
    }
    
    public var action: Action
    public var entity: String
    public var createFields: [FieldDefinition]
    public var deleteFields: [FieldName]
    
    public init(entity: String) {
        self.action = .create
        self.entity = entity
        self.createFields = []
        self.deleteFields = []
    }
}

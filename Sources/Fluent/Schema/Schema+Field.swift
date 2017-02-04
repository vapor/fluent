extension Schema {
    /**
        Various types of fields
        that can be used in a Schema.
    */
    public struct Field {
        public var name: String
        public var type: DataType
        public var optional: Bool
        public var unique: Bool
        public var `default`: Node?

        public enum DataType {
            case id(type: KeyType?)
            case int
            case string(length: Int?)
            case double
            case bool
            case data
            case custom(type: String)
        }
        
        public enum KeyType {
            case int
            case string(length: Int?)
            case custom(type: String)
            
            var dataType: DataType {
                switch self {
                case .int:
                    return .int
                case .string(let length):
                    return .string(length: length)
                case .custom(let type):
                    return .custom(type: type)
                }
            }
        }

        public init(
            name: String,
            type: DataType,
            optional: Bool = false,
            unique: Bool = false,
            default: Node? = nil
        ) {
            self.name = name
            self.type = type
            self.optional = optional
            self.unique = unique
            self.default = `default`
        }
        
        public init(
            name: String,
            type: DataType,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            let node: Node?
            
            if let d = `default` {
                node = try? d.makeNode()
            } else {
                node = nil
            }
            
            self.init(
                name: name,
                type: type,
                optional: optional,
                unique: unique,
                default: node
            )
        }
    }
}

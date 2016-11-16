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
            case id
            case int
            case string(length: Int?)
            case double
            case bool
            case data
            case custom(type: String)
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
    }
}

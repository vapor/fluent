extension Schema {
    /**
        Various types of fields
        that can be used in a Schema.
    */
    public struct Field {
        public var name: String
        public var type: DataType
        public var optional: Bool

        public enum DataType {
            case id
            case int
            case bigInt
            case string(length: Int?)
            case double
            case bool
            case data
            case json
        }

        public init(name: String, type: DataType, optional: Bool = false) {
            self.name = name
            self.type = type
            self.optional = optional
        }
    }
}

extension Schema {
    /**
        Creates a Schema.
     
        Cannot modify or delete fields.
    */
    public class Creator {
        public let entity: String
        public var fields: [Field]

        public init(_ entity: String) {
            self.entity = entity
            fields = []
        }

        public func id() {
            fields.append(.id)
        }

        public func int(_ name: String) {
            fields.append(.int(name))
        }

        public func string(_ name: String, length: Int? = nil) {
            fields.append(.string(name, length: length))
        }

        public func double(_ name: String, digits: Int? = nil, decimal: Int? = nil) {
            fields.append(.double(name, digits: digits, decimal: decimal))
        }

        public var schema: Schema {
            return .create(entity: entity, create: fields)
        }
    }
}

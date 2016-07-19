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

        public func id(
            _ name: String = "id",
            optional: Bool = false
        ) {
            fields += Field(name: name, type: .id, optional: optional)
        }

        public func int(
            _ name: String,
            optional: Bool = false
        ) {
            fields += Field(name: name, type: .int, optional: optional)
        }

        public func string(
            _ name: String,
            length: Int? = nil,
            optional: Bool = false
        ) {
            fields += Field(name: name, type: .string(length: length), optional: optional)
        }

        public func double(
            _ name: String,
            optional: Bool = false
        ) {
            fields += Field(name: name, type: .double, optional: optional)
        }

        public func bool(
            _ name: String,
            optional: Bool = false
        ) {
            fields += Field(name: name, type: .bool, optional: optional)
        }

        public func data(
            _ name: String,
            optional: Bool = false
            ) {
            fields += Field(name: name, type: .data, optional: optional)
        }

        public var schema: Schema {
            return .create(entity: entity, create: fields)
        }
    }
}

func +=(lhs: inout [Schema.Field], rhs: Schema.Field) {
    lhs.append(rhs)
}

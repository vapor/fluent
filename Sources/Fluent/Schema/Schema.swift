public enum Schema {
    case create(entity: String, create: [Field])
    case modify(entity: String, create: [Field], delete: [String])
    case delete(entity: String)
}

extension Schema {
    public enum Field {
        case id
        case int(String)
        case string(String, length: Int?)
        case double(String, digits: Int?, decimal: Int?)
    }
}

extension Schema {
    public class Modifier: Creator {
        public var delete: [String]

        public override init(_ entity: String) {
            delete = []
            super.init(entity)
        }

        public func delete(_ name: String) {
            delete.append(name)

        }

        public override var schema: Schema {
            return .modify(entity: entity, create: fields, delete: delete)
        }
    }

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


extension Database {
    public func modify(_ entity: String, closure: (Schema.Modifier) throws -> ()) throws {
        let modifier = Schema.Modifier(entity)
        try closure(modifier)
        _ = try driver.schema(modifier.schema)
    }

    public func create(_ entity: String, closure: (Schema.Creator) throws -> ()) throws {
        let creator = Schema.Creator(entity)
        try closure(creator)
        _ = try driver.schema(creator.schema)
    }

    public func delete(_ entity: String) throws {
        let schema = Schema.delete(entity: entity)
        _ = try driver.schema(schema)
    }
}

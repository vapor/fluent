public final class Schema {

    public static func build(_ entity: String, closure: (Builder) -> ()) throws {
        let builder = Builder(entity)
        closure(builder)
        _ = try Database.default.driver.build(builder)
    }

}

extension Schema {
    public enum Field {
        case int(String)
        case string(String, Int)
    }

    public final class Builder {
        public let entity: String
        public var fields: [Field]

        public init(_ entity: String) {
            self.entity = entity
            fields = []
        }

        public func int(_ name: String) {
            fields.append(.int(name))
        }

        public func string(_ name: String, length: Int = 128) {
            fields.append(.string(name, length))
        }
    }
}

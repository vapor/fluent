extension Schema {
    /**
        Modifies a schema. A subclass of Creator.
     
        Can modify or delete fields.
    */
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
}

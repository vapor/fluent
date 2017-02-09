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
        
        public func id(for entityType: Entity.Type, name: String = "id")
        {
            fields += Field(name: name, type: .id(keyType: entityType.idType))
        }

        public func int(
            _ name: String,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: name, 
                type: .int,
                optional: optional,
                unique: unique,
                default: `default`
            )
        }

        public func string(
            _ name: String,
            length: Int? = nil,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: name,
                type: .string(length: length),
                optional: optional,
                unique: unique,
                default: `default`
            )
        }

        public func double(
            _ name: String,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: name,
                type: .double,
                optional: optional,
                unique: unique,
                default: `default`
            )
        }

        public func bool(
            _ name: String,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: name,
                type: .bool,
                optional: optional,
                unique: unique,
                default: `default`
            )
        }

        public func data(
            _ name: String,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: name,
                type: .data,
                optional: optional,
                unique: unique,
                default: `default`
            )
        }

        public func custom(
            _ name: String,
            type: String,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: name,
                type: .custom(type: type),
                optional: optional,
                unique: unique,
                default: `default`
            )
        }

        public var schema: Schema {
            return .create(entity: entity, create: fields)
        }

        // MARK: Relations
        public func parent<E: Entity>(
            _ entity: E.Type = E.self,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            parent(
                idKey: "\(entity.name)_id",
                type: E.idType,
                optional: optional, 
                unique: unique, 
                default: `default`
            )
        }

        public func parent(
            idKey: String,
            type: Schema.Field.KeyType,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: idKey,
                type: type.fieldType,
                optional: optional,
                unique: unique,
                default: `default`
            )
        }
        
        public func pivotKeys(
            left: Entity.Type,
            right: Entity.Type,
            suffix: String
        ) {
            let leftKeyType = left.idType
            let rightKeyType = right.idType
            
            let leftName = "\(left.name)\(suffix)"
            let rightName = "\(right.name)\(suffix)"
            
            fields += Field(name: leftName,
                            type: leftKeyType.fieldType,
                            optional: false,
                            unique: false)
            
            fields += Field(name: rightName,
                            type: rightKeyType.fieldType,
                            optional: false,
                            unique: false)
        }
    }
}

func +=(lhs: inout [Schema.Field], rhs: Schema.Field) {
    lhs.append(rhs)
}

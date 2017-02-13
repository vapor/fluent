extension Schema {
    /// Creates schema.
    /// Cannot delete or modify fields.
    public class Creator {
        public let entity: String
        public var fields: [Field]

        public init(_ entity: String) {
            self.entity = entity
            fields = []
        }

        public func id<E: Entity>(for entityType: E.Type) {
            fields += Field(
                name: E.idKey,
                type: .id(type: E.idType)
            )
        }

        public func foreignId<E: Entity>(for entityType: E.Type) {
            fields += Field(
                name: E.foreignIdKey,
                type: .id(type: E.idType)
            )
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
                idKey: E.idKey,
                idType: E.idType,
                optional: optional, 
                unique: unique, 
                default: `default`
            )
        }

        public func parent(
            idKey: String,
            idType: IdentifierType,
            optional: Bool = false,
            unique: Bool = false,
            default: NodeRepresentable? = nil
        ) {
            fields += Field(
                name: idKey,
                type: .id(type: idType),
                optional: optional,
                unique: unique,
                default: `default`
            )
        }
    }
}

func +=(lhs: inout [Schema.Field], rhs: Schema.Field) {
    lhs.append(rhs)
}

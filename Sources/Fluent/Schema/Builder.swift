/// Represents any type of schema builder
public protocol Builder: class {
    var fields: [RawOr<Field>] { get set }
    var foreignKeys: [RawOr<ForeignKey>] { get set }
}

extension Builder {
    public func addField(_ field: Field) {
        fields.append(.some(field))
    }

    public func id<E: Entity>(for entityType: E.Type) {
        let field = Field(
            name: E.idKey,
            type: .id(type: E.idType),
            primaryKey: true
        )
        addField(field)
    }

    public func foreignId<E: Entity>(
        for entityType: E.Type,
        optional: Bool = false,
        unique: Bool = false
    ) {
        let field = Field(
            name: E.foreignIdKey,
            type: .id(type: E.idType),
            optional: optional,
            unique: unique
        )
        addField(field)
    }

    public func int(
        _ name: String,
        optional: Bool = false,
        unique: Bool = false,
        default: NodeRepresentable? = nil
    ) {
        let field = Field(
            name: name,
            type: .int,
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
    }

    public func string(
        _ name: String,
        length: Int? = nil,
        optional: Bool = false,
        unique: Bool = false,
        default: NodeRepresentable? = nil
    ) {
        let field = Field(
            name: name,
            type: .string(length: length),
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
    }

    public func double(
        _ name: String,
        optional: Bool = false,
        unique: Bool = false,
        default: NodeRepresentable? = nil
    ) {
        let field = Field(
            name: name,
            type: .double,
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
    }

    public func bool(
        _ name: String,
        optional: Bool = false,
        unique: Bool = false,
        default: NodeRepresentable? = nil
    ) {
        let field = Field(
            name: name,
            type: .bool,
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
    }

    public func bytes(
        _ name: String,
        optional: Bool = false,
        unique: Bool = false,
        default: NodeRepresentable? = nil
    ) {
        let field = Field(
            name: name,
            type: .bytes,
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
    }

    public func date(
        _ name: String,
        optional: Bool = false,
        unique: Bool = false,
        default: NodeRepresentable? = nil
    ) {
        let field = Field(
            name: name,
            type: .date,
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
    }

    public func custom(
        _ name: String,
        type: String,
        optional: Bool = false,
        unique: Bool = false,
        default: NodeRepresentable? = nil
    ) {
        let field = Field(
            name: name,
            type: .custom(type: type),
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
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
        let field = Field(
            name: idKey,
            type: .id(type: idType),
            optional: optional,
            unique: unique,
            default: `default`
        )
        addField(field)
    }
    
    // MARK: Foreign Key
    
    public func addForeignKey(_ foreignKey: ForeignKey) {
        foreignKeys.append(.some(foreignKey))
    }
    
    /// Adds a foreign key constraint from a local
    /// column to a column on the foreign entity.
    public func foreignKey<E: Entity>(
        _ field: String,
        references foreignField: String,
        on foreignEntity: E.Type = E.self
    ) {
        let foreignKey = ForeignKey(
            field: field,
            foreignField: foreignField,
            foreignEntity: foreignEntity
        )
        addForeignKey(foreignKey)
    }
    
    /// Adds a foreign key constraint from a local
    /// column to a column on the foreign entity.
    public func foreignKey<E: Entity>(
        for: E.Type = E.self
    ) {
        let foreignKey = ForeignKey(
            field: E.foreignIdKey,
            foreignField: E.idKey,
            foreignEntity: E.self
        )
        addForeignKey(foreignKey)
    }

    // MARK: Raw

    public func raw(_ string: String) {
        fields.append(.raw(string, []))
    }
}

/// Represents any type of schema builder
public protocol Builder: class {
    var entity: Entity.Type { get} 
    var fields: [RawOr<Field>] { get set }
    var foreignKeys: [RawOr<ForeignKey>] { get set }
}

/// Represents the way to create a foreign key constraint 
/// inside a foreign id field definition
public enum ForeignKeyCreation {
    /// The default behavior: created only if autoForeignKeys == true
    /// with an automatic name assigned
    case auto
    
    /// Created only if autoForeignKeys == true with custom name
    case autoWithName(String)
    
    /// The foreign key constraint is never created
    case none
    
    /// The foreign key created regardeless to autoForeignKeys,
    /// with an automatic name assigned
    case force

    /// The foreign key created regardeless to autoForeignKeys,
    /// with a custom name assigned
    case forceWithName(String)
}

extension Builder {
    public func field(_ field: Field) {
        fields.append(.some(field))
    }

    public func id() {
        let field = Field(
            name: entity.idKey,
            type: .id(type: entity.idType),
            primaryKey: true
        )
        self.field(field)
    }

    public func foreignId<E: Entity>(
        _ name: String = E.foreignIdKey,
        for entityType: E.Type,
        optional: Bool = false,
        unique: Bool = false,
        constraint fkCreation: ForeignKeyCreation = .auto
        ) {
        let field = Field(
            name: name,
            type: .id(type: E.idType),
            optional: optional,
            unique: unique
        )
        self.field(field)
        
        switch fkCreation {
            
        case .auto:
            if autoForeignKeys {
                self.foreignKey(name, references: E.idKey, on: E.self)
            }
            
        case .autoWithName(let fkName):
            if autoForeignKeys {
                self.foreignKey(name, references: E.idKey, on: E.self, name: fkName)
            }
            
        case .none:
            // Avoid the creation of the foreign key constraint
            break
            
        case .force:
            // Always creates the foreign key constraint, using the default name
            self.foreignKey(name, references: E.idKey, on: E.self)

        case .forceWithName(let fkName):
            // Always creates the foreign key constraint, using a custom name
            self.foreignKey(name, references: E.idKey, on: E.self, name: fkName)
            
        }
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
        self.field(field)
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
        self.field(field)
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
        self.field(field)
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
        self.field(field)
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
        self.field(field)
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
        self.field(field)
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
        self.field(field)
    }

    // MARK: Relations

    public func parent<E: Entity>(
        field name: String = E.foreignIdKey,
        _ entity: E.Type = E.self,
        optional: Bool = false,
        unique: Bool = false,
        constraint fkCreation: ForeignKeyCreation = .auto
    ) {
        foreignId(
            name,
            for: E.self,
            optional: optional,
            unique: unique,
            constraint: fkCreation
        )
    }
    
    public func owner<E: Entity>(
        _ name: String = E.foreignIdKey,
        of entity: E.Type = E.self,
        optional: Bool = false,
        unique: Bool = false,
        constraint fkCreation: ForeignKeyCreation = .auto
        ) {
        foreignId(
            name,
            for: entity,
            optional: optional,
            unique: unique,
            constraint: fkCreation
        )
    }
    
    public func lookup<E: Entity>(
        _ name: String = E.foreignIdKey,
        on entity: E.Type = E.self,
        optional: Bool = false,
        unique: Bool = false,
        constraint fkCreation: ForeignKeyCreation = .auto
        ) {
        foreignId(
            name,
            for: entity,
            optional: optional,
            unique: unique,
            constraint: fkCreation
        )
    }
    
    public func subclass<E: Entity>(
        _ name: String = E.foreignIdKey,
        of entity: E.Type = E.self,
        optional: Bool = false,
        unique: Bool = false,
        constraint fkCreation: ForeignKeyCreation = .auto
        ) {
        foreignId(
            name,
            for: entity,
            optional: optional,
            unique: unique,
            constraint: fkCreation
        )
    }
    
    // MARK: Foreign Key
    
    public func foreignKey(_ foreignKey: ForeignKey) {
        foreignKeys.append(.some(foreignKey))
    }
    
    /// Adds a foreign key constraint from a local
    /// column to a column on the foreign entity.
    public func foreignKey<E: Entity>(
        _ field: String,
        references foreignField: String,
        on foreignEntity: E.Type = E.self,
        name: String? = nil
    ) {
        let foreignKey = ForeignKey(
            entity: entity,
            field: field,
            foreignField: foreignField,
            foreignEntity: foreignEntity,
            name: name
        )
        self.foreignKey(foreignKey)
    }
    
    /// Adds a foreign key constraint from a local
    /// column to a column on the foreign entity.
    public func foreignKey<E: Entity>(
        for: E.Type = E.self
    ) {
        self.foreignKey(
            E.foreignIdKey,
            references: E.idKey,
            on: E.self
        )
    }

    /// Adds a foreign key constraint from a local
    /// column to a column on the foreign entity with
    /// a custom name
    public func foreignKey<E: Entity>(
        for: E.Type = E.self,
        idKey: String = E.foreignIdKey,
        name: String? = nil
        ) {
        self.foreignKey(
            idKey,
            references: E.idKey,
            on: E.self,
            name: name
        )
    }
    // MARK: Raw

    public func raw(_ string: String) {
        fields.append(.raw(string, []))
    }
}

public var autoForeignKeys = true

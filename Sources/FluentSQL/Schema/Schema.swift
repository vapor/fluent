/// A query that can be sent to a Fluent database.
public protocol Schema {
    associatedtype Action: SchemaAction
    associatedtype Field
    associatedtype FieldDefinition: SchemaFieldDefinition
        where FieldDefinition.Field == Field
    associatedtype Reference: SchemaReference
        where Reference.Field == Field
    associatedtype Index: SchemaIndex
        where Index.Field == Field

    static func fluentSchema(_ entity: String) -> Self

    static var fluentActionKey: WritableKeyPath<Self, Action> { get }


    static var fluentCreateFieldsKey: WritableKeyPath<Self, [FieldDefinition]> { get }
    static var fluentDeleteFieldsKey: WritableKeyPath<Self, [Field]> { get }

    static var fluentCreateReferencesKey: WritableKeyPath<Self, [Reference]> { get }
    static var fluentDeleteReferencesKey: WritableKeyPath<Self, [Reference]> { get }

    static var fluentCreateIndexesKey: WritableKeyPath<Self, [Index]> { get }
    static var fluentDeleteIndexesKey: WritableKeyPath<Self, [Index]> { get }
}


extension Schema {
    internal var fluentAction: Action {
        get { return self[keyPath: Self.fluentActionKey] }
        set { self[keyPath: Self.fluentActionKey] = newValue }
    }

    /// The fields to add to this schema
    internal var fluentCreateFields: [FieldDefinition] {
        get { return self[keyPath: Self.fluentCreateFieldsKey] }
        set { self[keyPath: Self.fluentCreateFieldsKey] = newValue }
    }

    /// The fields to be removed from this schema.
    internal var fluentDeleteFields: [Field] {
        get { return self[keyPath: Self.fluentDeleteFieldsKey] }
        set { self[keyPath: Self.fluentDeleteFieldsKey] = newValue }
    }

    internal var fluentCreateReferences: [Reference] {
        get { return self[keyPath: Self.fluentCreateReferencesKey] }
        set { self[keyPath: Self.fluentCreateReferencesKey] = newValue }
    }

    internal var fluentDeleteReferences: [Reference] {
        get { return self[keyPath: Self.fluentDeleteReferencesKey] }
        set { self[keyPath: Self.fluentDeleteReferencesKey] = newValue }
    }

    internal var fluentCreateIndexes: [Index] {
        get { return self[keyPath: Self.fluentCreateIndexesKey] }
        set { self[keyPath: Self.fluentCreateIndexesKey] = newValue }
    }

    internal var fluentDeleteIndexes: [Index] {
        get { return self[keyPath: Self.fluentDeleteIndexesKey] }
        set { self[keyPath: Self.fluentDeleteIndexesKey] = newValue }
    }
}


public protocol SchemaFieldDefinition {
    associatedtype Field
    associatedtype DataType: SchemaDataType

    static func fluentFieldDefinition(_ field: Field, _ dataType: DataType, isIdentifier: Bool) -> Self
}

public protocol SchemaDataType {
    static func fluentType(_ type: Any.Type) -> Self
}

private extension DataDefinitionForeignKey {
    func sqlName() -> String {
        return "\(local.table ?? "*").\(local.name)_\(foreign.table ?? "*").\(foreign.name)"
    }
}

public protocol SchemaReference {
    associatedtype Actions: SchemaReferenceActions
    associatedtype Field: PropertySupporting

    static func fluentReference(base: Field, referenced: Field, actions: Actions) -> Self
}

public protocol SchemaIndex {
    associatedtype Field: PropertySupporting
    /// Creates a new `SchemaIndex`.
    ///
    /// - parameters:
    ///     - fields: The indexed fields.
    ///     - isUnique: If `true`, this index will also force uniqueness.
    static func fluentIndex(fields: [Field], isUnique: Bool) -> Self
}

/// Actions that will take place when a reference is modified.
public protocol SchemaReferenceActions {
    associatedtype ActionType
    /// The default `ReferentialActions`
    static var `default`: Self { get }
}


/// Helps you create and execute a database schema.
public protocol SchemaBuilder: class {
    associatedtype Model
        where Model: Fluent.Model, Model.Database: SchemaSupporting

    /// The schema query being built.
    var schema: Model.Database.Schema { get set }

    /// Create a new `Schema.Builder`.
    init(_ type: Model.Type)
}

extension SchemaBuilder {
    @discardableResult
    public func id(type: Model.Database.Schema.FieldDefinition.DataType = .fluentType(Model.ID.self)) -> Model.Database.Schema.FieldDefinition {
        return field(.fluentFieldDefinition(.keyPath(Model.idKey), type, isIdentifier: true))
    }

    /// Adds a field to the schema.
    @discardableResult
    public func field<T>(type: Model.Database.Schema.FieldDefinition.DataType = .fluentType(T.self), for key: KeyPath<Model, T>) -> Model.Database.Schema.FieldDefinition {
        return field(.fluentFieldDefinition(.keyPath(key), type, isIdentifier: key == Model.idKey))
    }

    /// Adds a field to the schema.
    @discardableResult
    public func field(type: Model.Database.Schema.FieldDefinition.DataType, field: Model.Database.Schema.Reference.Field, isIdentifier: Bool = false) -> Model.Database.Schema.FieldDefinition {
        return self.field(.fluentFieldDefinition(field, type, isIdentifier: false))
    }

    @discardableResult
    public func field(_ field: Model.Database.Schema.FieldDefinition) -> Model.Database.Schema.FieldDefinition {
        schema.fluentCreateFields.append(field)
        return field
    }
}

/// A schema builder specifically for creating
/// new tables and collections.
public final class SchemaCreator<Model>: SchemaBuilder
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{
    /// See `SchemaBuilder`.
    public var schema: Model.Database.Schema

    /// See `SchemaBuilder`.
    public init(_ type: Model.Type = Model.self) {
        self.schema = .fluentSchema(Model.entity)
        schema.fluentAction = .fluentCreate
    }
}

/// Updates schemas, capable of deleting fields.
public final class SchemaUpdater<Model>: SchemaBuilder
    where Model: Fluent.Model, Model.Database: SchemaSupporting
{
    /// See `SchemaBuilder`.
    public var schema: Model.Database.Schema

    /// See `SchemaBuilder`.
    public init(_ type: Model.Type = Model.self) {
        self.schema = .fluentSchema(Model.entity)
        schema.fluentAction = .fluentUpdate
    }

    /// Removes a field from the schema.
    public func removeField<T>(for field: KeyPath<Model, T>) {
        removeField(.keyPath(field))
    }

    /// Deletes the field with the supplied name.
    public func removeField(_ field: Model.Database.Schema.Field) {
        schema.fluentDeleteFields.append(field)
    }
}

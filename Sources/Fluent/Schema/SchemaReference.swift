import Async

/// Internal type-erasing protocol.
/// Note: do not use this type externally.
public protocol ReferenceConfigurable {
    /// Enables references errors.
    func enableReferences() -> Future<Void>

    /// Disables reference errors.
    func disableReferences() -> Future<Void>
}

/// Defines database types that support references
public protocol ReferenceSupporting: SchemaSupporting where Connection: ReferenceConfigurable { }

/// A reference / foreign key is a field (or collection of fields) in one table
/// that uniquely identifies a row of another table or the same table.
public struct SchemaReference<Database> where Database: ReferenceSupporting & SchemaSupporting {
    /// The base field.
    public let base: QueryField

    /// The field this base field references.
    /// Note: this is a `QueryField` because we have limited info.
    /// we assume it is the same type as the base field.
    public let referenced: QueryField

    /// Creates a new SchemaReference
    public init(
        base: QueryField,
        referenced: QueryField
    ) {
        self.base = base
        self.referenced = referenced
    }

    /// Convenience init w/ schema field
    public init(base: SchemaField<Database>, referenced: QueryField) {
        self.base = QueryField(entity: nil, name: base.name)
        self.referenced = referenced
    }
}

extension DatabaseSchema where Database: ReferenceSupporting {
    /// Field to field references for this database schema.
    public var addReferences: [SchemaReference<Database>] {
        get { return extend["add-references"] as? [SchemaReference<Database>] ?? [] }
        set { extend["add-references"] = newValue }
    }

    /// Field to field references for this database schema.
    public var removeReferences: [SchemaReference<Database>] {
        get { return extend["remove-references"] as? [SchemaReference<Database>] ?? [] }
        set { extend["remove-references"] = newValue }
    }
}

extension SchemaBuilder where Model.Database: ReferenceSupporting {
    /// Adds a field to the schema and creates a reference.
    /// T : T
    public func field<T, Other>(
        for key: KeyPath<Model, T>,
        referencing: KeyPath<Other, T>
    ) throws
        where Other: Fluent.Model
    {
        let base = try field(for: key)
        let reference = try SchemaReference(base: base, referenced: referencing.makeQueryField())
        schema.addReferences.append(reference)
    }

    /// Adds a field to the schema and creates a reference.
    /// T : Optional<T>
    public func field<T, Other>(
        for key: KeyPath<Model, T>,
        referencing: KeyPath<Other, Optional<T>>
    ) throws
        where Other: Fluent.Model
    {
        let base = try field(for: key)
        let reference = try SchemaReference(base: base, referenced: referencing.makeQueryField())
        schema.addReferences.append(reference)
    }

    /// Adds a field to the schema and creates a reference.
    /// Optional<T> : T
    public func field<T, Other>(
        for key: KeyPath<Model, Optional<T>>,
        referencing: KeyPath<Other, T>
    ) throws
        where Other: Fluent.Model
    {
        let base = try field(for: key)
        let reference = try SchemaReference(base: base, referenced: referencing.makeQueryField())
        schema.addReferences.append(reference)
    }

    /// Adds a field to the schema and creates a reference.
    /// Optional<T> : Optional<T>
    public func field<T, Other>(
        for key: KeyPath<Model, Optional<T>>,
        referencing: KeyPath<Other, Optional<T>>
    ) throws
        where Other: Fluent.Model
    {
        let base = try field(for: key)
        let reference = try SchemaReference<Model.Database>(base: base, referenced: referencing.makeQueryField())
        schema.addReferences.append(reference)
    }

    /// Adds a field to the schema and creates a reference.
    /// Optional<T> : Optional<T>
    public func remove<T, Other>(
        for key: KeyPath<Model, Optional<T>>,
        referencing: KeyPath<Other, Optional<T>>
    ) throws
        where Other: Fluent.Model
    {
        let base = try field(for: key)
        let reference = try SchemaReference<Model.Database>(base: base, referenced: referencing.makeQueryField())
        schema.addReferences.append(reference)
    }

    /// Adds a field to the schema.
    public func removeField<Field, T, Other>(
        for field: Field,
        referencing: KeyPath<Other, Optional<T>>
    ) throws
        where Field: QueryFieldRepresentable
    {
        try removeField(for: field)
        try removeReference(from: field, to: referencing)
    }

    /// Adds a field to the schema.
    public func removeReference<Field, T, Other>(
        from field: Field,
        to referencing: KeyPath<Other, Optional<T>>
    ) throws
        where Field: QueryFieldRepresentable
    {
        let reference = try SchemaReference<Model.Database>(
            base: field.makeQueryField(),
            referenced: referencing.makeQueryField()
        )
        schema.removeReferences.append(reference)
    }
}

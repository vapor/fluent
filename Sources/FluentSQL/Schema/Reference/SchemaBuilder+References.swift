/// MARK: Field convenience

extension Schema.Builder where Model.Database: ReferenceSupporting {
    /// Adds a field to the schema and creates a reference.
    /// T : T
    public func field<T, Other>(for key: KeyPath<Model, T>, referencing: KeyPath<Other, T>, actions: Schema.Reference.Actions = .default) where Other: Fluent.Model {
        field(for: key)
        addReference(from: key, to: referencing, actions: actions)
    }

    /// Adds a field to the schema and creates a reference.
    /// T : T?
    public func field<T, Other>(for key: KeyPath<Model, T>, referencing: KeyPath<Other, T?>, actions: Schema.Reference.Actions = .default) where Other: Fluent.Model {
        field(for: key)
        addReference(from: key, to: referencing, actions: actions)
    }

    /// Adds a field to the schema and creates a reference.
    /// T? : T
    public func field<T, Other>(for key: KeyPath<Model, T?>, referencing: KeyPath<Other, T>, actions: Schema.Reference.Actions = .default)
        where Other: Fluent.Model
    {
        field(for: key)
        addReference(from: key, to: referencing, actions: actions)
    }

    /// Adds a field to the schema and creates a reference.
    /// T? : T?
    public func field<T, Other>(for key: KeyPath<Model, T?>, referencing: KeyPath<Other, T?>, actions: Schema.Reference.Actions = .default)
        where Other: Fluent.Model
    {
        field(for: key)
        addReference(from: key, to: referencing, actions: actions)
    }
}

/// MARK: Add

extension Schema.Builder where Model.Database: ReferenceSupporting {
    /// Adds a reference.
    /// T : T
    public func addReference<T, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, T>, actions: Schema.Reference.Actions = .default)
        where Other: Fluent.Model
    {
        _addReference(from: base, to: referenced, actions: actions)
    }

    /// Adds a reference.
    /// T? : T
    public func addReference<T, Other>(from base: KeyPath<Model, T?>, to referenced: KeyPath<Other, T>, actions: Schema.Reference.Actions = .default)
        where Other: Fluent.Model
    {
        _addReference(from: base, to: referenced, actions: actions)
    }

    /// Adds a reference.
    /// T : T?
    public func addReference<T, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, T?>, actions: Schema.Reference.Actions = .default)
        where Other: Fluent.Model
    {
        _addReference(from: base, to: referenced, actions: actions)
    }

    /// Internal add reference. Does not verify types match.
    private func _addReference<T, U, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, U>, actions: Schema.Reference.Actions)
        where Other: Fluent.Model
    {
        let reference = Schema<Model.Database>.Reference(
            base: .keyPath(base),
            referenced: .keyPath(referenced),
            actions: actions
        )
        schema.addReferences.append(reference)
    }
}

/// MARK: Remove

extension Schema.Builder where Model.Database: ReferenceSupporting {
    /// Removes a reference.
    /// T : T
    public func removeReference<T, Other>(from field: KeyPath<Model, T>, to referencing: KeyPath<Other, T>)
        where Other: Fluent.Model
    {
        _removeReference(from: field, to: referencing)
    }

    /// Removes a reference.
    /// T? : T
    public func removeReference<T, Other>(from field: KeyPath<Model, T?>, to referencing: KeyPath<Other, T>)
        where Other: Fluent.Model
    {
        _removeReference(from: field, to: referencing)
    }

    /// Removes a reference.
    /// T : T?
    public func removeReference<T, Other>(from field: KeyPath<Model, T>, to referencing: KeyPath<Other, T?>)
        where Other: Fluent.Model
    {
        _removeReference(from: field, to: referencing)
    }

    /// Internal remove reference. Does not verify types match.
    private func _removeReference<T, U, Other>(from base: KeyPath<Model, T>, to referenced: KeyPath<Other, U>)
        where Other: Fluent.Model
    {
        let reference = Schema<Model.Database>.Reference(
            base: .keyPath(base),
            referenced: .keyPath(referenced),
            actions: .default
        )
        schema.removeReferences.append(reference)
    }
}

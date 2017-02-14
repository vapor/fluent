/// Represents an entity that can be
/// stored and retrieved from the `Database`.
public protocol Entity: Preparation, NodeConvertible, Relatable {
    /// DELETE ME
    var exists: Bool { get set }
    var id: Node? { get set }

    /// The type of identifier this model uses.
    /// ex: INT, UUID, etc
    static var idType: IdentifierType { get }

    /// Called before the entity will be created.
    /// Throwing will cancel the creation.
    func willCreate() throws

    /// Called after the entity has been created.
    func didCreate()

    /// Called before the entity will be updated.
    /// Throwing will cancel the update.
    func willUpdate() throws

    /// Called after the entity has been updated.
    func didUpdate()

    /// Called before the entity will be deleted.
    /// Throwing will cancel the deletion.
    func willDelete() throws

    /// Called after the entity has been deleted.
    func didDelete()
}

// MARK: Optional

extension Entity {
    public func willCreate() {}
    public func didCreate() {}
    public func willUpdate() {}
    public func didUpdate() {}
    public func willDelete() {}
    public func didDelete() {}
}

// MARK: CRUD

extension Entity {
    /// Persists the entity into the
    /// data store and sets the `id` property.
    public mutating func save() throws {
        try Self.query().save(&self)
    }

    /// Deletes the entity from the data
    /// store if the `id` property is set.
    public func delete() throws {
        try Self.query().delete(self)
    }

    /// Returns all entities for this `Model`.
    public static func all() throws -> [Self] {
        return try Self.query().all()
    }

    /// Finds the entity with the given `id`.
    public static func find(_ id: NodeRepresentable) throws -> Self? {
        guard let _ = database else { return nil }
        return try Self.query().filter(Self.idKey, .equals, id).first()
    }

    //// Creates a `Query` instance for this `Model`.
    public static func query() throws -> Query<Self> {
        guard let db = database else {
            throw EntityError.noDatabase(self)
        }
        return Query(db)
    }
}

// MARK: Deprecated
extension Entity {
    public var exists: Bool {
        // TODO: Implement me
        get { return false }
        set { }
    }
}

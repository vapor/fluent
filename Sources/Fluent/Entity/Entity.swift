import Foundation

/**
    Represents an entity that can be
    stored and retrieved from the `Database`.
*/
public protocol Entity: Preparation, NodeConvertible {
    /// The collection or table name for this entity.
    static var entity: String { get }

    /**
        The name to use for internal storage.

        This should be left as the default 
        implementation except for special cases
        like pivots.
    */
    static var name: String { get }
    
    /**
        The name of the column that corresponds
        to this entity's key.
     
        The default return is 'database.driver.idKey',
        and if no database is set, 'id' is returned,
        instead.
     */
    static var idKey: String { get }

    /// The name of the column that points
    /// to this entity's id when referenced
    /// from other tables or collections.
    static var foreignIdKey: String { get }
    
    /**
        The entity's primary identifier.
        This is the same value used for
        `find(:_)`.
    */
    var id: Node? { get set }

    /// The type of identifier this model uses.
    /// ex: INT, UUID, etc
    static var idType: IdentifierType { get }

    /// Called before the entity will be created.
    func willCreate() throws

    /// Called after the entity has been created.
    func didCreate() throws

    /// Called before the entity will be updated.
    func willUpdate() throws

    /// Called after the entity has been updated.
    func didUpdate() throws

    /// Called before the entity will be deleted.
    func willDelete() throws

    /// Called after the entity has been deleted.
    func didDelete() throws

    var exists: Bool { get set }
}

// MARK: Defaults

extension Entity {
    /**
        The default entity is the
        lowercase model pluralized.
    */
    public static var entity: String {
        return name + "s"
    }

    public static var name: String {
        return String(describing: self).lowercased()
    }
    
    public static var idType: IdentifierType {
        return database?.driver.idType ?? .uuid
    }

    public static var idKey: String {
        return database?.driver.idKey ?? "id"
    }

    public static var foreignIdKey: String {
        return "\(name)_\(idKey)"
    }
}


extension Entity {
    public func willCreate() {}
    public func didCreate() {}
    public func willUpdate() {}
    public func didUpdate() {}
    public func willDelete() {}
    public func didDelete() {}
}

//MARK: CRUD

extension Entity {
    /// Persists the entity into the
    /// data store and sets the `id` property.
    public mutating func save() throws {
        try Self.query().save(&self)
    }

    /**
        Deletes the entity from the data
        store if the `id` property is set.
    */
    public func delete() throws {
        try Self.query().delete(self)
    }

    /**
        Returns all entities for this `Model`.
    */
    public static func all() throws -> [Self] {
        return try Self.query().all()
    }

    /**
        Finds the entity with the given `id`.
    */
    public static func find(_ id: NodeRepresentable) throws -> Self? {
        guard let _ = database else { return nil }
        return try Self.query().filter(Self.idKey, .equals, id).first()
    }

    /**
        Creates a `Query` instance for this `Model`.
    */
    public static func query() throws -> Query<Self> {
        guard let db = database else {
            throw EntityError.noDatabase
        }
        return Query(db)
    }
}

public enum EntityError: Error {
    case noDatabase
}

//MARK: Database

extension Entity {
    /**
        Fetches or sets the `Database` for this
        `Model` from the static database map.
    */
    public static var database: Database? {
        get {
            if let db = Database.map[Self.name] {
                return db
            } else {
                return Database.default
            }
        }
        set {
            Database.map[Self.name] = newValue
        }
    }
}

extension Entity {
    public var exists: Bool {
        // TODO: Implement me
        get { return false }
        set { }
    }
}

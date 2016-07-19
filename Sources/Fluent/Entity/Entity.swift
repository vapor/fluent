import Foundation

/**
    Represents an entity that can be
    stored and retrieved from the `Database`.
*/
public protocol Entity: CustomStringConvertible, Preparation, NodeConvertible {
    /**
        The `Database` this model will use.
        It can be changed at any point.
    */
    static var database: Database { get set }

    /**
        The collection or table name
        for this entity.
    */
    static var entity: String { get }

    /**
        The entity's primary identifier.
        This is the same value used for
        `find(:_)`.
    */
    var id: Node? { get set }
}

//MARK: Defaults

extension Entity {
    /**
        The default entity is the
        lowercase model pluralized.
    */
    public static var entity: String {
        return name + "s"
    }

    public static var name: String {
        return String(self).lowercased()
    }
}

//MARK: CRUD

extension Entity {
    /**
        Persists the entity into the 
        data store and sets the `id` property.
    */
    public mutating func save() throws {
        try Self.query.save(&self)
    }

    /**
        Deletes the entity from the data
        store if the `id` property is set.
    */
    public func delete() throws {
        try Self.query.delete(self)
    }

    /**
        Returns all entities for this `Model`.
    */
    public static func all() throws -> [Self] {
        return try Self.query.all()
    }

    /**
        Finds the entity with the given `id`.
    */
    public static func find(_ id: Node) throws -> Self? {
        return try Self.query.filter(database.driver.idKey, .equals, id).first()
    }

    /**
        Creates a `Query` instance for this `Model`.
    */
    public static var query: Query<Self> {
        return Query()
    }

    /**
        Creates a `Query` with a first filter.
    */
    @discardableResult
    public static func filter(_ field: String, _ comparison: Filter.Comparison, _ value: NodeRepresentable) -> Query<Self> {
        return query.filter(field, comparison, value)
    }

    @discardableResult
    public static func filter(_ field: String, _ value: NodeRepresentable) -> Query<Self> {
        return filter(field, .equals, value)
    }
}

//MARK: Database

extension Entity {
    /**
        Fetches or sets the `Database` for this
        `Model` from the static database map.
    */
    public static var database: Database {
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

//MARK: CustomStringConvertible

extension Entity {
    public var description: String {
        var readable: [String: String] = [:]

        makeNode().object?.forEach { key, val in
            readable[key] = val.string ?? "nil"
        }

        return "[\(id)] \(readable)"
    }
}

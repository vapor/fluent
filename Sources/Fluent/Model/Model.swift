import Foundation

/**
    Represents an entity that can be
    stored and retrieved from the `Database`.
*/
public protocol Model: CustomStringConvertible, Preparation {
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
    var id: Value? { get set }

    /**
        Creates a representation of the entity 
        suitable for storing in the database.
     
        For SQL databases, this usually means a 
        flat dictionary of keys and values.
     
        For NoSQL databses, arrays and dictionaries 
        can be stored in a hierarchy.
    */
    func serialize() -> [String: Value?]

    /**
        Initializes an entity
        from the database representation.
    */
    init(serialized: [String: Value])
}

//MARK: Defaults

extension Model {
    /**
        The default entity is the
        lowercase model pluralized.
    */
    public static var entity: String {
        return String(self).lowercased() + "s"
    }
}

//MARK: CRUD

extension Model {
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
    public static func find(_ id: Value) throws -> Self? {
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
    public static func filter(_ field: String, _ comparison: Filter.Comparison, _ value: Value) -> Query<Self> {
        return query.filter(field, comparison, value)
    }

    @discardableResult
    public static func filter(_ field: String, _ value: Value) -> Query<Self> {
        return filter(field, .equals, value)
    }
}

//MARK: Database

extension Model {
    private static var name: String {
        return "\(self)"
    }

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

extension Model {
    public var description: String {
        var readable: [String: String] = [:]

        serialize().forEach { key, val in
            readable[key] = val?.string ?? "nil"
        }

        return "[\(id)] \(readable)"
    }
}
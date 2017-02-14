/// Objects conforming to this protocol
/// can be used in relational queries.
public protocol Relatable {
    /// The plural relational name of this model.
    /// Used as the collection or table name.
    static var entity: String { get }

    /// The singular relational name of this model.
    /// Also used for internal storage.
    static var name: String { get }

    /// The type of identifier used for both
    /// the local and foreign id keys.
    /// ex: uuid, integer, etc
    static var idType: IdentifierType { get }

    /// The name of the column that corresponds
    /// to this entity's identifying key.
    /// The default is 'database.driver.idKey',
    /// and then "id"
    static var idKey: String { get }

    /// The name of the column that points
    /// to this entity's id when referenced
    /// from other tables or collections.
    static var foreignIdKey: String { get }
}

extension Relatable {
    /// See Relatable.entity
    public static var entity: String {
        return name + "s"
    }

    /// See Relatable.name
    public static var name: String {
        return String(describing: self).lowercased()
    }

    /// See Relatable.idType
    public static var idType: IdentifierType {
        return database?.driver.idType ?? .uuid
    }

    /// See Relatable.idKey
    public static var idKey: String {
        return database?.driver.idKey ?? "id"
    }

    /// See Relatable.foreignIdKey
    public static var foreignIdKey: String {
        return "\(name)_\(idKey)"
    }
}

// MARK: Database

extension Relatable {
    /// Fetches or sets the `Database` for this
    /// relatable object from the static database map.
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

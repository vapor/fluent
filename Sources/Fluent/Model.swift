
public protocol Model: CustomStringConvertible {
    static var database: Database { get set }

    static var entity: String { get }
    var id: Value? { get set }

    func serialize() -> [String: Value?]
    init(serialized: [String: Value])
}

//MARK: Defaults

extension Model {
    public static var entity: String {
        return String(self).lowercased() + "s"
    }
}

//MARK: CRUD

extension Model {
    public mutating func save() throws {
        try Self.database.query().save(&self)
    }

    public func delete() throws {
        try Self.database.query().delete(self)
    }

    public static func all() throws -> [Self] {
        return try Self.database.query().all()
    }
    
    public static func find(_ id: Value) throws -> Self? {
        return try Self.database.query().filter(database.driver.idKey, .Equals, id).first()
    }

    public static var query: Query<Self> {
        return Query()
    }
}

//MARK: Database

extension Model {
    public static var name: String {
        return "\(self)"
    }
    
    public static var database: Database {
        get {
            if let db = Database.map[Self.name] {
                return db
            } else {
                let db = Database()
                Database.map[Self.name] = db
                return db
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

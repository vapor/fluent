
public protocol Model: Entity {
    static var database: Database { get }
}

extension Model {
    public static var database: Database {
        return Database()
    }
    
    public func save() throws {
        try Self.database.query().save(self)
    }
    
    public static func saveMany<T: Model>(_ models: [T]) throws {
        for model in models {
            try model.save()
        }
    }
    
    public func delete() throws {
        try Self.database.query().delete(self)
    }

    public static func all() throws -> [Self] {
        return try Self.database.query().all()
    }
    
    public static func find(_ ids: Value...) throws -> [Self] {
        let result: [Self] = try Self.database.query().filter("id", in: ids).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
        
    }
    
    public static func find(_ id: Value) throws -> Self {
        guard let result: Self = try Self.database.query().filter("id", .Equals, id).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func find(_ field: String, _ comparison: Filter.Comparison, _ value: Value) throws -> [Self] {
        let result: [Self] = try Self.database.query().filter(field, comparison, value).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func find(_ field: String, in value: [Value]) throws -> [Self] {
        let result: [Self] = try Self.database.query().filter(field, in: value).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func take(_ count: Int = 1) throws -> [Self] {
        let result: [Self] = try Self.database.query().limit(count).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func first(_ count: Int = 1) throws -> Self {
        guard let result: Self = try Self.database.query().sort("id", .Ascending).limit(count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func last(_ count: Int = 1) throws -> Self {
        guard let result: Self = try Self.database.query().sort("id", .Descending).limit(count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
}
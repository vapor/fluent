
public protocol Model: Entity {}

public extension Model {
    public func save() {
        Query.save(self)
    }
    
    public static func saveMany<T: Model>(_ models: [T]) {
        for model in models {
            model.save()
        }
    }
    
    public func delete() throws {
        try Query.delete(self)
    }
    
    public static func all() throws -> [Self] {
        return try Query().all()
    }
    
    public static func find(_ ids: String...) throws -> [Self] {
        let result: [Self] = try Query().filter(where: "id" =~ ids).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
        
    }
    
    public static func find(_ id: String) throws -> Self {
        guard let result: Self = try Query().filter(where: "id" == id).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func find(where filter: Filter) throws -> [Self] {
        let result: [Self] = try Query().filter(where: filter).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func take(_ count: Int = 1) throws -> [Self] {
        let result: [Self] = try Query().take(count).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func first(_ count: Int = 1) throws -> Self {
        let query = Query(Self)
        
        guard let result = try query.sort(by: "id", direction: .ascending).take(count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func last(_ count: Int = 1) throws -> Self {
        guard let result: Self = try Query().sort(by: "id", direction: .descending).take(count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func from(_ data: [String:Value]) throws -> Self {
        return try Unbox(data)
    }
    
    public func serialize() throws -> [String: Value] {
        return try Wrap(self)
    }
}

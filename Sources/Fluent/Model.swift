
public protocol Entity {
    static var entity: String { get }
    var id: String? { get }
    
    func serialize() -> [String: Value?]
    init(serialized: [String: Value])
}

public protocol Model: Entity {}

extension Model {    
    public func save() throws {
        try Query().save(self)
    }
    
    public static func saveMany<T: Model>(models: [T]) throws {
        for model in models {
            try model.save()
        }
    }
    
    public func delete() throws {
        try Query().delete(self)
    }

    public static func all() throws -> [Self] {
        return try Query().all()
    }
    
    public static func find(ids: Value...) throws -> [Self] {
        let result: [Self] = try Query().filter("id", in: ids).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
        
    }
    
    public static func find(id: Value) throws -> Self {
        guard let result: Self = try Query().filter("id", .Equals, id).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func find(field: String, _ comparison: Filter.Comparison, _ value: Value) throws -> [Self] {
        let result: [Self] = try Query().filter(field, comparison, value).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func find(field: String, in value: [Value]) throws -> [Self] {
        let result: [Self] = try Query().filter(field, in: value).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func take(count: Int = 1) throws -> [Self] {
        let result: [Self] = try Query().limit(count).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func first(count: Int = 1) throws -> Self {
        guard let result: Self = try Query().sort("id", .Ascending).limit(count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func last(count: Int = 1) throws -> Self {
        guard let result: Self = try Query().sort("id", .Descending).limit(count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
}

public protocol Model {
    static var entity: String { get }
    var id: String? { get }
    
    func serialize() -> [String: Value?]
    init(serialized: [String: Value])
}

extension Model {    
    public func save() throws {
        try Query().save(model: self)
    }
    
    public static func saveMany<T: Model>(models: [T]) throws {
        for model in models {
            try model.save()
        }
    }
    
    public func delete() throws {
        try Query().delete(model: self)
    }

    public static func all() throws -> [Self] {
        return try Query().all()
    }
    
    public static func find(ids: Value...) throws -> [Self] {
		let result: [Self] = try Query().filter(field: "id", in: ids).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
        
    }
    
    public static func find(id: Value) throws -> Self {
        guard let result: Self = try Query().filter(field: "id", .Equals, id).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func find(field: String, _ comparison: Filter.Comparison, _ value: Value) throws -> [Self] {
        let result: [Self] = try Query().filter(field: field, comparison, value).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func find(field: String, in value: [Value]) throws -> [Self] {
		let result: [Self] = try Query().filter(field: field, in: value).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func take(count: Int = 1) throws -> [Self] {
		let result: [Self] = try Query().limit(count: count).all()
        guard result.count > 0 else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func first(count: Int = 1) throws -> Self {
		guard let result: Self = try Query().sort(field: "id", .Ascending).limit(count: count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
    
    public static func last(count: Int = 1) throws -> Self {
		guard let result: Self = try Query().sort(field: "id", .Descending).limit(count: count).first() else {
            throw ModelError.NotFound(message: "Model not found")
        }
        return result
    }
}
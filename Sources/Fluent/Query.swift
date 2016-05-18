public class Query<T: Model> {

    public var action: Action
    public var filters: [Filter]
    public var data: [String: Value?]?
    public var limit: Limit?
    public var entity: String {
        return T.entity
    }

    var database: Database

    init() {
        filters = []
        action = .fetch
        database = T.database
    }

    public func first() throws -> T? {
        limit = Limit(count: 1)
        return try run().first
    }

    public func all() throws -> [T] {
        return try run()
    }
    
    func run() throws -> [T] {
        var models: [T] = []
        
        let results = try database.driver.execute(self)
        
        for result in results {
            var model = T(serialized: result)
            model.id = result[database.driver.idKey]
            models.append(model)
        }
        
        return models
    }
    
    public func save(_ model: inout T) throws -> T {
        let data = model.serialize()

        if let id = model.id {
            filter(database.driver.idKey, .equals, id)
            try update(data)
        } else {
            let new = try create(data)
            model.id = new?.id
        }

        return model
    }
    
    public func delete() throws {
        action = .delete
        try run()
    }
    
    public func delete(_ model: T) throws {
        guard let id = model.id else {
            return
        }
        action = .delete
        
        let filter = Filter.compare(database.driver.idKey, .equals, id)
        filters.append(filter)
        
        try run()
    }
    
    public func update(_ serialized: [String: Value?]) throws {
        action = .update
        data = serialized
        try run()
    }

    public func create(_ serialized: [String: Value?]) throws -> T? {
        action = .create
        data = serialized

        let results = try run()
        guard results.count > 0 else {
            return nil
        }
        return results[0]
    }
    
    public func filter(_ field: String, _ value: Value) -> Self {
        return filter(field, .equals, value)
    }
    
    public func filter(_ field: String, _ scope: Filter.Scope, _ set: [Value]) -> Self {
        let filter = Filter.subset(field, scope, set)
        filters.append(filter)
        return self
    }
    
    public func filter(_ field: String, _ comparison: Filter.Comparison, _ value: Value) -> Self {
        let filter = Filter.compare(field, comparison, value)
        filters.append(filter)
        return self
    }

}

extension Query: CustomStringConvertible {
    public var description: String {
        return "\(action) \(entity), \(filters.count) filters"
    }
}

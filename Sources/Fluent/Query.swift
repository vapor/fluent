public class Query<T: Model> {
    public typealias FilterHandler = (query: Query) -> Query
    public var filters: [Filter]
    
    public var sorts: [Sort]
    public var unions: [Union]
    public var fields: [String]
    public var data: [String: Value?]?
    public var limit: Limit?
    public var offset: Offset?
    public var action: Action
    public var entity: String {
        return T.entity
    }

    var database: Database
    
    init() {
        fields = []
        filters = []
        sorts = []
        unions = []
        action = .select
        database = T.database
    }

    public func first(_ fields: String...) throws -> T? {
        limit = Limit(count: 1)
        return try run(fields).first
    }
    
    public func all(_ fields: String...) throws -> [T] {
        return try run(fields)
    }
    
    func run(_ fields: [String]? = nil) throws -> [T] {
        if let fields = fields {
            self.fields += fields
        }
        
        var models: [T] = []
        
        let results = try database.driver.execute(self)
        
        for result in results {
            let id = result[database.driver.idKey]

            var filtered = result
            filtered.removeValue(forKey: database.driver.idKey)

            var model = T(serialized: result)
            model.id = id
            models.append(model)
        }
        
        return models
    }
    
    public func save(_ model: inout T) throws -> T {
        let data = model.serialize()

        if let id = model.id {
            try filter(database.driver.idKey, .Equals, id).update(data)
        } else {
            let new = try insert(data)
            if let new = new {
                model.id = new.id
            }
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
        
        let filter = Filter.Compare(database.driver.idKey, .Equals, id)
        filters.append(filter)
        
        try run()
    }
    
    public func update(_ serialized: [String: Value?]) throws {
        action = .update
        data = serialized
        try run()
    }

    public func insert(_ serialized: [String: Value?]) throws -> T? {
        action = .insert
        data = serialized

        let results = try run()
        guard results.count > 0 else {
            return nil
        }
        return results[0]
    }
    
    public func filter(_ field: String, _ value: Value) -> Self {
        return filter(field, .Equals, value)
    }
    
    public func filter(_ field: String, in superSet: [Value]) -> Self {
        let filter = Filter.Subset(field, .In, superSet)
        filters.append(filter)
        return self
    }
    
    public func filter(_ field: String, _ comparison: Filter.Comparison, _ value: Value) -> Self {
        let filter = Filter.Compare(field, comparison, value)
        filters.append(filter)
        return self
    }

}

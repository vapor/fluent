public class Query<T: Model> {
    public typealias FilterHandler = (query: Query) -> Query
    public var filters: [Filter]
    
    public var sorts: [Sort]
    public var unions: [Union]
    public var fields: [String]
    public var items: [String: Value?]?
    public var limit: Limit?
    public var offset: Offset?
    public var action: Action
    public var entity: String {
        return T.entity
    }

    var database: Database
    
    public init(database: Database) {
        fields = []
        filters = []
        sorts = []
        unions = []
        action = .Select(false)
        self.database = database
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
        
        let results = try database.execute(self)
        
        for result in results {
            let model = T(serialized: result)
            models.append(model)
        }
        
        return models
    }
    
    public func save(_ model: T) throws -> T {
        let data = model.serialize()

        if let id = model.id {
            try filter("id", .Equals, id).update(data)
        } else {
            try insert(data)
        }
        return model
    }
    
    public func delete() throws {
        action = .Delete
        try run()
    }
    
    public func delete(_ model: T) throws {
        guard let id = model.id else {
            throw ModelError.NoID(message: "Model has no id")
        }
        action = .Delete
        
        let filter = Filter.Compare("id", .Equals, id)
        filters.append(filter)
        
        try run()
    }
    
    public func update(_ items: [String: Value?]) throws {
        action = .Update
        self.items = items
        try run()
    }

    public func insert(_ items: [String: Value?]) throws {
        action = .Insert
        self.items = items
        try run()
    }
    
    public func filter(_ field: String, _ value: Value) -> Self {
        let filter = Filter.Compare(field, .Equals, value)
        filters.append(filter)
        return self
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
    
    public func sort(_ field: String, _ direction: Sort.Direction) -> Self {
        let sort = Sort(field: field, direction: direction)
        sorts.append(sort)
        return self
    }
    
    public func limit(_ count: Int = 1) -> Self {
        limit = Limit(count: count)
        return self
    }
    
    public func offset(_ count: Int = 1) -> Self {
        offset = Offset(count: count)
        return self
    }
    
    public func or(_ handler: FilterHandler) -> Self {
        let q = handler(query: Query(database: database))
        let filter = Filter.Group(.Or, q.filters)
        filters.append(filter)
        return self
    }

    public func and(_ handler: FilterHandler) -> Self {
        let q = handler(query: Query(database: database))
        let filter = Filter.Group(.And, q.filters)
        filters.append(filter)
        return self
    }
    
    public func join<T: Model>(_ type: T.Type, _ operation: Union.Operation = .Default, foreignKey: String? = nil, otherKey: String? = nil) -> Self? {
        let fk = foreignKey ?? "\(type.entity).\(entity)_id"
        let ok = otherKey ?? "\(entity).id"
        let union = Union(entity: type.entity, foreignKey: fk, otherKey: ok, operation: operation)
        unions.append(union)
        return self
    }
    
    public func distinct() -> Self {
        action = .Select(true)
        return self
    }

    public func list(_ key: String) throws -> [Value] {
        let results = try database.execute(self)
        return results.reduce([]) {
            var newArr = $0
            if let value = $1[key] {
                newArr.append(value)
            }
            return newArr
        }
    }
    
    public func count(_ field: String = "*") throws -> Int {
        let result = try aggregate(.Count, field: field)
        guard let value = Int(result["COUNT(\(field))"]?.string ?? "0") else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func average(_ field: String = "*") throws -> Double {
        let result = try aggregate(.Average, field: field)
        guard let value = Double(result["AVG(\(field))"]?.string ?? "0") else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func maximum(_ field: String = "*") throws -> Double {
        let result = try aggregate(.Maximum, field: field)
        guard let value = Double(result["MAX(\(field))"]?.string ?? "0") else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func minimum(_ field: String = "*") throws -> Double {
        let result = try aggregate(.Minimum, field: field)
        guard let value = Double(result["MIN(\(field))"]!.string!) else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func sum(_ field: String = "*") throws -> Double {
        let result = try aggregate(.Sum, field: field)
        
        guard let value = Double(result["SUM(\(field))"]!.string!) else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    private func aggregate(_ action: Action, field: String) throws -> [String: Value] {
        self.action = action
        self.fields = [field]
        let results = try database.execute(self)
        guard results.count > 0 else {
            throw QueryError.NoResult(message: "No results found")
        }
        return results.first!
    }
}


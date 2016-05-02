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
    
    public init() {
        fields = []
        filters = []
        sorts = []
        unions = []
        action = .Select(false)
    }
    
    public func first(fields: String...) throws -> T? {
        limit = Limit(count: 1)
        return try run(fields: fields).first
    }
    
    public func all(fields: String...) throws -> [T] {
        return try run(fields: fields)
    }
    
    func run(fields: [String]? = nil) throws -> [T] {
        if let fields = fields {
            self.fields += fields
        }
        
        var models: [T] = []
        
        let results = try Database.driver.execute(query: self)
        
        for result in results {
            let model = T(serialized: result)
            models.append(model)
        }
        
        return models
    }
    
    public func save(model: T) throws -> T {
        let data = model.serialize()

        if let id = model.id {
            try filter(field: "id", .Equals, id).update(items: data)
        } else {
            try insert(items: data)
        }
        return model
    }
    
    public func delete() throws {
        action = .Delete
        try run()
    }
    
    public func delete(model: T) throws {
        guard let id = model.id else {
            throw ModelError.NoID(message: "Model has no id")
        }
        action = .Delete
        
        let filter = Filter.Compare("id", .Equals, id)
        filters.append(filter)
        
        try run()
    }
    
    public func update(items: [String: Value?]) throws {
        action = .Update
        self.items = items
        try run()
    }

    public func insert(items: [String: Value?]) throws {
        action = .Insert
        self.items = items
        try run()
    }
    
    public func filter(field: String, _ value: Value) -> Self {
        let filter = Filter.Compare(field, .Equals, value)
        filters.append(filter)
        return self
    }
    
    public func filter(field: String, in superSet: [Value]) -> Self {
        let filter = Filter.Subset(field, .In, superSet)
        filters.append(filter)
        return self
    }
    
    
    public func filter(field: String, _ comparison: Filter.Comparison, _ value: Value) -> Self {
        let filter = Filter.Compare(field, comparison, value)
        filters.append(filter)
        return self
    }
    
    public func sort(field: String, _ direction: Sort.Direction) -> Self {
        let sort = Sort(field: field, direction: direction)
        sorts.append(sort)
        return self
    }
    
    public func limit(count: Int = 1) -> Self {
        limit = Limit(count: count)
        return self
    }
    
    public func offset(count: Int = 1) -> Self {
        offset = Offset(count: count)
        return self
    }
    
    public func or(handler: FilterHandler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.Or, q.filters)
        filters.append(filter)
        return self
    }

    public func and(handler: FilterHandler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.And, q.filters)
        filters.append(filter)
        return self
    }
    
    public func join<T: Model>(type: T.Type, _ operation: Union.Operation = .Default, foreignKey: String? = nil, otherKey: String? = nil) -> Self? {
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

    public func list(key: String) throws -> [Value] {
        let results = try Database.driver.execute(query: self)
        return results.reduce([]) {
            var newArr = $0
            if let value = $1[key] {
                newArr.append(value)
            }
            return newArr
        }
    }
    
    public func count(field: String = "*") throws -> Int {
        let result = try aggregate(action: .Count, field: field)
        guard let value = Int(result["COUNT(\(field))"]!.string) else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func average(field: String = "*") throws -> Double {
        let result = try aggregate(action: .Average, field: field)
        guard let value = Double(result["AVG(\(field))"]!.string) else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func maximum(field: String = "*") throws -> Double {
        let result = try aggregate(action: .Maximum, field: field)
        guard let value = Double(result["MAX(\(field))"]!.string) else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func minimum(field: String = "*") throws -> Double {
        let result = try aggregate(action: .Minimum, field: field)
        guard let value = Double(result["MIN(\(field))"]!.string) else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func sum(field: String = "*") throws -> Double {
        let result = try aggregate(action: .Sum, field: field)
        
        guard let value = Double(result["SUM(\(field))"]!.string) else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    private func aggregate(action: Action, field: String) throws -> [String: Value] {
        self.action = action
        self.fields = [field]
        let results = try Database.driver.execute(query: self)
        guard results.count > 0 else {
            throw QueryError.NoResult(message: "No results found")
        }
        return results.first!
    }
}


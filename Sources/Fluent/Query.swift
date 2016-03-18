public class Query<T: Model> {
    public typealias FilterHandler = (query: Query) -> Query
    public var filters: [Filter]
    
    var fields: [String]
    var limit: Limit?
    var offset: Offset?
    var action: Action
    var items: [String: Value]?
    var sorts: [Sort]
    var unions: [Union]
    var entity: String {
        return T.entity
    }
    
    public init() {
        fields = []
        filters = []
        sorts = []
        unions = []
        action = .Select(false)
    }
    
    public func first(fields: String...) -> T? {
        limit = Limit(count: 1)
        return run(fields)?.first
    }
    
    public func all(fields: String...) -> [T]? {
        return run(fields)
    }
    
    func run(fields: [String]? = nil) -> [T]? {
        if let fields = fields {
            self.fields += fields
        }
        
        var models: [T] = []
        
        guard let results = try? Database.driver.execute(self) else {
            return nil
        }
        
        for result in results {
            let model = T(serialized: result)
            models.append(model)
        }
        
        return models
    }
    
    
    public func save(model: T) -> T {
        let data = model.serialize()

        if let id = model.id {
            filter("id", .Equals, id).update(data)
        } else {
            insert(data)
        }
        return model
    }
    
    public func delete(model: T? = nil) {
        action = .Delete
        
        if let id = model?.id {
            let filter = Filter.Compare("id", .Equals, id)
            filters.append(filter)
        }
        
        run()
    }
    
    public func update(items: [String: Value]) {
        action = .Update
        self.items = items
        run()
    }

    public func insert(items: [String: Value]) {
        action = .Insert
        self.items = items
        run()
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
    
    public func performQuery(string: String) -> Self {
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
    
    public func join<T: Model>(type: T.Type, _ operation: Union.Operation = .Default) -> Self? {
        let union = Union(entity: type.entity, operation: operation)
        unions.append(union)
        return self
    }
    
    public func distinct() -> Self {
        action = .Select(true)
        return self
    }

    public func list(key: String) -> [Value]? {
        guard let results = try? Database.driver.execute(self) else {
            return nil
        }
        
        var items = [Value]()
        for result in results {
            for (k, v) in result {
                if k == key {
                    items.append(v)
                }
            }
        }
        return items
    }
    
    // MARK: - Aggregate
    
    public func count(field: String = "*") -> Int? {
        guard let result = aggregate(.Count, field: field) else {
            return nil
        }
        return Int(result["COUNT(\(field))"]!.string)
    }
    
    public func avg(field: String = "*") -> Double? {
        guard let result = aggregate(.Average, field: field) else {
            return nil
        }
        return Double(result["AVG(\(field))"]!.string)
    }
    
    public func max(field: String = "*") -> Double? {
        guard let result = aggregate(.Maximum, field: field) else {
            return nil
        }
        return Double(result["MAX(\(field))"]!.string)
    }
    
    public func min(field: String = "*") -> Double? {
        guard let result = aggregate(.Minimum, field: field) else {
            return nil
        }
        return Double(result["MIN(\(field))"]!.string)
    }
    
    public func sum(field: String = "*") -> Double? {
        guard let result = aggregate(.Sum, field: field) else {
            return nil
        }
        return Double(result["SUM(\(field))"]!.string)
    }
    
    private func aggregate(action: Action, field: String) -> [String: Value]? {
        self.action = action
        self.fields = [field]
        guard let results = try? Database.driver.execute(self) else {
            return nil
        }
        return results.first
    }
}
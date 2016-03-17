public enum Action {
    case Select
    case Delete
    case Insert
    case Update
    case Count
    case Maximum
    case Minimum
    case Average
    case Sum
}

public class Query<T: Model> {

    
    var entity: String {
        return T.entity
    }
    
    var fields: [String]
    
    var limit: Limit?
    var action: Action
    
    public var filters: [Filter]
    var sorts: [Sort]
    var unions: [Union]
    
    public init() {
        fields = []
        filters = []
        sorts = []
        unions = []
        action = .Select
    }
    
    public func first(fields: String...) -> T? {
        action = .Select
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
    
    
    public func save(model: T) {
        let data = model.serialize()

        if let id = model.id {
            filter("id", .Equals, id).update(data)
        } else {
            insert(data)
        }
    }
    
    public func delete(model: T? = nil) {
        action = .Delete
        
        if let id = model?.id {
            let filter = ComparisonFilter("id", .Equals, id)
            filters.append(filter)
        }
        
        run()
    }
    
    public func update(items: [String: Value]) {
        action = .Update
        //context.data = items
        run()
    }

    public func insert(items: [String: Value]) {
        action = .Insert
        //context.data = items
        run()
    }
    
    public func filter(field: String, in superSet: [Value]) -> Self {
        let filter = SubsetFilter(field: field, superSet: superSet)
        filters.append(filter)
        
        return self
    }
    
    public func filter(field: String, _ comparison: ComparisonFilter.Comparison, _ value: Value) -> Self {
        let filter = ComparisonFilter(field, comparison, value)
        filters.append(filter)
        
        return self
    }
    
    public func sort(field: String, _ direction: Sort.Direction) -> Self {
        let sort = Sort(field: field, direction: direction)
        sorts.append(sort)
        return self
    }
    
    public func groupBy(field: String) -> Self {
        //context.groupBy = field
        return self
    }
    
    public func limit(count: Int = 1) -> Self {
        limit = Limit(count: count)
        return self
    }
    
    public func offset(count: Int = 1) -> Self {
        //context.offset = count
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
    
    public func performQuery(string: String) -> Self {
        return self
    }
    
    public func join<T: Model>(type: T.Type, _ operation: Union.Operation = .Default) -> Self? {
        let union = Union(entity: type.entity, operation: operation)
        unions.append(union)
        
        return self
    }
    
    public func distinct() -> Self {
        //context.distinct = true
        return self
    }

    // MARK: - Aggregate

    /*
    public func count(key: String = "*") -> Int? {
        guard let result = aggregate(.COUNT(key)) else {
            return nil
        }
        return Int(result["COUNT(\(key))"]!.string)
    }

    public func avg(key: String = "*") -> Double? {
        guard let result = aggregate(.AVG(key)) else {
            return nil
        }
        return Double(result["AVG(\(key))"]!.string)
    }

    public func max(key: String = "*") -> Double? {
        guard let result = aggregate(.MAX(key)) else {
            return nil
        }
        return Double(result["MAX(\(key))"]!.string)
    }

    public func min(key: String = "*") -> Double? {
        guard let result = aggregate(.MIN(key)) else {
            return nil
        }
        return Double(result["MIN(\(key))"]!.string)
    }

    public func sum(key: String = "*") -> Double? {
        guard let result = aggregate(.SUM(key)) else {
            return nil
        }
        return Double(result["SUM(\(key))"]!.string)
    }
    
    private func aggregate(clause: Clause) -> [String: Value]? {
        //context.clause = clause
        guard let results = try? Database.driver.execute(self) else {
            return nil
        }
        return results.first
    }*/
}
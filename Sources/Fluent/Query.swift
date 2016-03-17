
public class Query<T: Model> {
    private var context: DSGenerator = SQL() // default
    
    public init(entity: String? = nil) {
        context.entity = entity ?? T.entity
    }
    
    public func first(fields: String...) -> T? {
        return run(fields)?.first
    }
    
    public func all(fields: String...) -> [T]? {
        return run(fields)
    }
    
    func run(fields: [String]? = nil) -> [T]? {
        context.fields = fields ?? []
        var models: [T] = []
        
        guard let results = try? Database.driver.execute(self) else {
            return nil
        }
        
        for result in results {
            let model = T(deserialize: result)
            models.append(model)
        }
        
        return models
    }
    
    public func using(context: DSGenerator) -> Self {
        self.context = context
        return self
    }
    
    public func save(model: T) {
        let data = model.serialize()

        if let id = model.id {
            with("id", .Equals, id).update(data)
        } else {
            insert(data)
        }
    }
    
    public func delete(model: T? = nil) {
        context.clause = .DELETE
        
        if let id = model?.id {
            context.entity = T.entity
            context.operation.append( ("id", .Equals, [id]))
        }
        
        run()
    }
    
    public func update(items: [String: Value]) {
        context.clause = .UPDATE
        context.data = items
        run()
    }

    public func insert(items: [String: Value]) {
        context.clause = .INSERT
        context.data = items
        run()
    }
    
    public func with(key: String, _ op: Operator, _ values: Value...) -> Self {
        context.operation.append((key, op, values))
        return self
    }
    
    public func _with(key: String, _ op: Operator, _ values: [Value]) -> Self {
        context.operation.append((key, op, values))
        return self
    }
    
    public func andWith(key: String, _ op: Operator, _ values: Value...) -> Self {
        context.operation.append((key, op, values))
        context.andIndexes.append(context.operation.count - 1)
        return self
    }
    
    public func orWith(key: String, _ op: Operator, _ values: Value...) -> Self {
        context.operation.append((key, op, values))
        context.orIndexes.append(context.operation.count - 1)
        return self
    }
    
    public func orderBy(key: String, _ order: OrderBy) -> Self {
        context.orderBy.append((key, order))
        return self
    }
    
    public func groupBy(field: String) -> Self {
        context.groupBy = field
        return self
    }
    
    public func limit(count: Int = 1) -> Self {
        context.limit = count
        return self
    }
    
    public func offset(count: Int = 1) -> Self {
        context.offset = count
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
    
/*
     SELECT role.* FROM user
     INNER JOIN user_role on user_role.role_id = role.id
     INNER JOIN role on user_role.user_id = user.id
*/
    public func join(table: Model.Type, _ type: Join = .Inner) -> Self? {
        switch context.clause {
        case .SELECT:
            context.joins.append((table.entity, type))
            return self
        default:
            return nil
        }
    }
    
    public func distinct() -> Self {
        context.distinct = true
        return self
    }

    // MARK: - Aggregate

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
        context.clause = clause
        guard let results = try? Database.driver.execute(self) else {
            return nil
        }
        return results.first
    }
}
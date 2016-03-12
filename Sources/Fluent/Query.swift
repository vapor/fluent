
public class Query<T: Model> {
    private(set) var entity: String
    private var statement: StatementGenerator
    
    public init(entity: String? = nil) {
        self.entity = entity ?? T.entity
        statement = Database.driver.statementGenerator.init()
    }
    
    public func first(fields: String...) -> T? {
        return run(fields)?.first
    }
    
    public func all(fields: String...) -> [T]? {
        return run(fields)
    }
    
    public func run(fields: [String]? = nil) -> [T]? {
        statement.fields = fields ?? []
        var models: [T] = []
        
        guard let results = Database.driver.execute(statement) else {
            return nil
        }
        
        for result in results {
            let model = T(deserialize: result)
            models.append(model)
        }
        
        return models
    }
    
    public func save(model: T) {
        let data = model.serialize()

        if let id = model.id {
            update(data).with("id", .Equals, id).run()
        } else {
            insert(data).run()
        }
    }
    
    public func delete(model: T? = nil) {
        statement.clause = .DELETE
        
        if let id = model?.id {
            statement.entity = T.entity
            statement.operation.append( ("id", .Equals, [id]))
        }
        
        run()
    }
    
    public func update(items: [String: StatementValueType]) -> Self {
        statement.clause = .UPDATE
        statement.data = items
        return self
    }

    public func insert(items: [String: StatementValueType]) -> Self {
        statement.clause = .INSERT
        statement.data = items
        return self
    }
    
    public func with(key: String, _ op: Operator, _ values: StatementValueType...) -> Self {
        statement.operation.append((key, op, values))
        return self
    }
    
    public func _with(key: String, _ op: Operator, _ values: [StatementValueType]) -> Self {
        statement.operation.append((key, op, values))
        return self
    }
    
    public func andWith(key: String, _ op: Operator, _ values: StatementValueType...) -> Self {
        statement.operation.append((key, op, values))
        statement.andIndexes.append(statement.operation.count - 1)
        return self
    }
    
    public func orWith(key: String, _ op: Operator, _ values: StatementValueType...) -> Self {
        statement.operation.append((key, op, values))
        statement.orIndexes.append(statement.operation.count - 1)
        return self
    }
    
    public func orderBy(key: String, _ order: OrderBy) -> Self {
        statement.orderBy.append((key, order))
        return self
    }
    
    public func groupBy(field: String) -> Self {
        statement.groupBy = field
        return self
    }
    
    public func limit(count: Int = 1) -> Self {
        statement.limit = count
        return self
    }
    
    public func offset(count: Int = 1) -> Self {
        statement.offset = count
        return self
    }
    
    public func list(key: String) -> [StatementValueType]? {
        guard let results = Database.driver.execute(statement) else {
            return nil
        }
        
        var items = [StatementValueType]()
        
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
        switch statement.clause {
        case .SELECT:
            statement.joins.append((table.entity, type))
            return self
        default:
            return nil
        }
    }
    
    public func distinct() -> Self {
        statement.distinct = true
        return self
    }

    // MARK: - Aggregate

    public func count(key: String = "*") -> Int? {
        guard let result = aggregate(.COUNT(key)) else {
            return nil
        }
        return Int(result["COUNT(\(key))"]!.asString)
    }

    public func avg(key: String = "*") -> Double? {
        guard let result = aggregate(.AVG(key)) else {
            return nil
        }
        return Double(result["AVG(\(key))"]!.asString)
    }

    public func max(key: String = "*") -> Double? {
        guard let result = aggregate(.MAX(key)) else {
            return nil
        }
        return Double(result["MAX(\(key))"]!.asString)
    }

    public func min(key: String = "*") -> Double? {
        guard let result = aggregate(.MIN(key)) else {
            return nil
        }
        return Double(result["MIN(\(key))"]!.asString)
    }

    public func sum(key: String = "*") -> Double? {
        guard let result = aggregate(.SUM(key)) else {
            return nil
        }
        return Double(result["SUM(\(key))"]!.asString)
    }
    
    private func aggregate(clause: Clause) -> [String: StatementValueType]? {
        statement.clause = clause
        guard let results = Database.driver.execute(statement) else {
            return nil
        }
        return results.first
    }
}
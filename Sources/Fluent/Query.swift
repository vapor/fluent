public class Query<E: Entity>: CustomStringConvertible {
    var parameters = QueryParameters<E>()
    
    public var description: String {
        var dict = [String:Any]()
        
        dict["filter"] = parameters.filter
        dict["fields"] = parameters.fields
        dict["offset"] = parameters.offset
        dict["limit"] = parameters.limit
        dict["sorts"] = parameters.sorts
        
        return String(dict)
    }
    
    public init(_ entityType: E.Type = E.self) {}
    
    public func first(fields: [String]? = nil) throws -> E? {
        return try take(1).fetch().first
    }
    
    public func all(fields: [String]? = nil) throws -> [E] {
        return try fetch()
    }
    
    public static func save(_ entity: E) -> E {
        if let updatedEntity = try? update(entity) {
            return updatedEntity
        }
        
        return insert(entity)
    }
    
    public static func save(_ entities: [E]) -> [E] {
        return entities.map { entity in save(entity) }
    }
    
    public func update(with data: [String: Value]) throws -> [E] {
        // TODO: implement real update functionality
        return []
    }
    
    public static func update(_ entity: E) throws -> E {
        guard let id = entity.id else {
            throw ModelError.NoID(message: "Entity has no id")
        }
        
        let query = Query(E).filter(where: "id" == id)
        
        return try query.update(with: Wrap(entity)).first!
    }
    
    public static func update(_ entities: [E]) throws -> [E] {
        return try entities.map { entity in try update(entity) }
    }
    
    public static func insert(_ entity: E) -> E {
        // TODO: implement real insert functionality
        return entity
    }
    
    public func delete() {
        // TODO: implement real delete functionality
    }
    
    public static func delete(_ entity: E) throws {
        try delete([entity])
    }
    
    public static func delete(_ entities: [E]) throws {
        let ids: [String] = try entities.map { entity in
            guard let id = entity.id else {
                throw ModelError.NoID(message: "Entity has no id")
            }
            
            return id
        }
        
        Query(E).filter(where: "id" =~ ids).delete()
    }
    
    func fetch() throws -> [E] {
        return try run().map { try Unbox($0) }
    }
    
    func run(with fields: [String]? = nil) throws -> [[String:Value]] {
        // TODO: implement real run functionality
        return []
    }
    
    public func filter(_ operation: Filter.Operation = .and, where newFilter: Filter) -> Self {
        if let existingFilter = parameters.filter {
            switch operation {
            case .and: parameters.filter = .both(existingFilter,   and: newFilter)
            case .or:  parameters.filter = .either(existingFilter, or:  newFilter)
            }
        } else {
            parameters.filter = newFilter
        }
        
        return self
    }
    
    public func and(where filter: Filter) -> Self {
        return self.filter(.and, where: filter)
    }
    
    public func or(where filter: Filter) -> Self {
        return self.filter(.or, where: filter)
    }
    
    public func sort(by field: String, direction: Sort.Direction) -> Self {
        parameters.sorts.append(Sort(field: field, direction: direction))
        
        return self
    }
    
    public func skip(_ amount: Int) -> Self {
        parameters.offset.amount = amount
        
        return self
    }
    
    public func take(_ amount: Int) -> Self {
        parameters.limit = Limit(amount: amount)
        
        return self
    }
    
    public func chunk(per amount: Int, closure: [E] throws -> Bool) throws {
        var chunk: [E]
        var `continue` = true
        
        parameters.limit = Limit(amount: amount)
        
        while `continue` {
            chunk = try fetch()
            
            if chunk.isEmpty {
                break
            }
            
            `continue` = try closure(chunk)
            
            parameters.offset.amount += amount
        }
    }
    
    public func list(key: String) throws -> [Value] {
        return try run().flatMap { row in row[key] }
    }
    
    public func list<T: protocol<Hashable,Value>>(key: String, value: String) throws -> [T:Value] {
        var result = [T:Value]()
        
        for row in try run() {
            if let key = row[key] as? T, let value = row[value] {
                result[key] = value
            }
        }
        
        return result
    }
    
    public func count(_ field: String = "*") throws -> Int {
        guard let value = try aggregate(.count, field: field).int else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func average(_ field: String = "*") throws -> Double {
        guard let value = try aggregate(.average, field: field).double else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func maximum(_ field: String = "*") throws -> Double {
        guard let value = try aggregate(.maximum, field: field).double else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func minimum(_ field: String = "*") throws -> Double {
        guard let value = try aggregate(.minimum, field: field).double else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    public func sum(_ field: String = "*") throws -> Double {
        guard let value = try aggregate(.sum, field: field).double else {
            throw QueryError.InvalidValue(message: "Result value was invalid")
        }
        return value
    }
    
    private func aggregate(_ action: Action, field: String) throws -> Value {
        parameters.action = action
        parameters.fields = [field]
        let results = try Database.driver.execute(parameters)
        
        guard let result = results.first?.values.first else {
            throw QueryError.NoResult(message: "No results found")
        }
        
        return result
    }
}

public struct QueryParameters<E: Entity> {
    public var limit:  Limit?
    public var filter: Filter?
    public var joins: [Join] = []
    public var sorts:  [Sort] = []
    public var fields: [String] = []
    public var unions: [Query<E>] = []
    public var items: [String: Value?]?
    public var entity: String = E.entity
    public var offset: Offset = Offset(amount: 0)
    public var action: Action = .select(distinct: false)
}

// public class Query<T: Model> {
//     public typealias FilterHandler = (query: Query) -> Query
//     public var filters: [Filter]
    
//     public var sorts: [Sort]
//     public var unions: [Union]
//     public var fields: [String]
//     public var items: [String: Value?]?
//     public var limit: Limit?
//     public var offset: Offset?
//     public var action: Action
//     public var entity: String {
//         return T.entity
//     }
    
//     public init() {
//         fields = []
//         filters = []
//         sorts = []
//         unions = []
//         action = .Select(false)
//     }
    
//     public func first(_ fields: String...) throws -> T? {
//         limit = Limit(count: 1)
//         return try run(fields).first
//     }
    
//     public func all(_ fields: String...) throws -> [T] {
//         return try run(fields)
//     }
    
//     func run(_ fields: [String]? = nil) throws -> [T] {
//         if let fields = fields {
//             self.fields += fields
//         }
        
//         var models: [T] = []
        
//         let results = try Database.driver.execute(self)
        
//         for result in results {
//             let model = T(serialized: result)
//             models.append(model)
//         }
        
//         return models
//     }
    
//     public func save(_ model: T) throws -> T {
//         let data = model.serialize()

//         if let id = model.id {
//             try filter("id", .Equals, id).update(data)
//         } else {
//             try insert(data)
//         }
//         return model
//     }
    
//     public func delete() throws {
//         action = .Delete
//         try run()
//     }
    
//     public func delete(_ model: T) throws {
//         guard let id = model.id else {
//             throw ModelError.NoID(message: "Model has no id")
//         }
//         action = .Delete
        
//         let filter = Filter.Compare("id", .Equals, id)
//         filters.append(filter)
        
//         try run()
//     }
    
//     public func update(_ items: [String: Value?]) throws {
//         action = .Update
//         self.items = items
//         try run()
//     }

//     public func insert(_ items: [String: Value?]) throws {
//         action = .Insert
//         self.items = items
//         try run()
//     }
    
//     public func filter(_ field: String, _ value: Value) -> Self {
//         let filter = Filter.Compare(field, .Equals, value)
//         filters.append(filter)
//         return self
//     }
    
//     public func filter(_ field: String, in superSet: [Value]) -> Self {
//         let filter = Filter.Subset(field, .In, superSet)
//         filters.append(filter)
//         return self
//     }
    
    
//     public func filter(_ field: String, _ comparison: Filter.Comparison, _ value: Value) -> Self {
//         let filter = Filter.Compare(field, comparison, value)
//         filters.append(filter)
//         return self
//     }
    
//     public func sort(_ field: String, _ direction: Sort.Direction) -> Self {
//         let sort = Sort(field: field, direction: direction)
//         sorts.append(sort)
//         return self
//     }
    
//     public func limit(_ count: Int = 1) -> Self {
//         limit = Limit(count: count)
//         return self
//     }
    
//     public func offset(_ count: Int = 1) -> Self {
//         offset = Offset(count: count)
//         return self
//     }
    
//     public func or(_ handler: FilterHandler) -> Self {
//         let q = handler(query: Query())
//         let filter = Filter.Group(.Or, q.filters)
//         filters.append(filter)
//         return self
//     }

//     public func and(_ handler: FilterHandler) -> Self {
//         let q = handler(query: Query())
//         let filter = Filter.Group(.And, q.filters)
//         filters.append(filter)
//         return self
//     }
    
//     public func join<T: Model>(_ type: T.Type, _ operation: Union.Operation = .Default, foreignKey: String? = nil, otherKey: String? = nil) -> Self? {
//         let fk = foreignKey ?? "\(type.entity).\(entity)_id"
//         let ok = otherKey ?? "\(entity).id"
//         let union = Union(entity: type.entity, foreignKey: fk, otherKey: ok, operation: operation)
//         unions.append(union)
//         return self
//     }
    
//     public func distinct() -> Self {
//         action = .Select(true)
//         return self
//     }

//     public func list(_ key: String) throws -> [Value] {
//         let results = try Database.driver.execute(self)
//         return results.reduce([]) {
//             var newArr = $0
//             if let value = $1[key] {
//                 newArr.append(value)
//             }
//             return newArr
//         }
//     }
    
//     public func count(_ field: String = "*") throws -> Int {
//         let result = try aggregate(.Count, field: field)
//         guard let value = Int(result["COUNT(\(field))"]!.string) else {
//             throw QueryError.InvalidValue(message: "Result value was invalid")
//         }
//         return value
//     }
    
//     public func average(_ field: String = "*") throws -> Double {
//         let result = try aggregate(.Average, field: field)
//         guard let value = Double(result["AVG(\(field))"]!.string) else {
//             throw QueryError.InvalidValue(message: "Result value was invalid")
//         }
//         return value
//     }
    
//     public func maximum(_ field: String = "*") throws -> Double {
//         let result = try aggregate(.Maximum, field: field)
//         guard let value = Double(result["MAX(\(field))"]!.string) else {
//             throw QueryError.InvalidValue(message: "Result value was invalid")
//         }
//         return value
//     }
    
//     public func minimum(_ field: String = "*") throws -> Double {
//         let result = try aggregate(.Minimum, field: field)
//         guard let value = Double(result["MIN(\(field))"]!.string) else {
//             throw QueryError.InvalidValue(message: "Result value was invalid")
//         }
//         return value
//     }
    
//     public func sum(_ field: String = "*") throws -> Double {
//         let result = try aggregate(.Sum, field: field)
        
//         guard let value = Double(result["SUM(\(field))"]!.string) else {
//             throw QueryError.InvalidValue(message: "Result value was invalid")
//         }
//         return value
//     }
    
//     private func aggregate(_ action: Action, field: String) throws -> [String: Value] {
//         self.action = action
//         self.fields = [field]
//         let results = try Database.driver.execute(self)
//         guard results.count > 0 else {
//             throw QueryError.NoResult(message: "No results found")
//         }
//         return results.first!
//     }
// }


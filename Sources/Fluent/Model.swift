
public protocol Model {
    static var entity: String { get }
    var id: String? { get }
    
    func serialize() -> [String: Value]
    init(deserialize: [String: Value])
}

extension Model {    
    public func save() {
        Query().save(self)
    }
    
    public static func saveMany<T: Model>(models: [T]) {
        for model in models {
            model.save()
        }
    }
    
    public func delete() {
        Query().delete(self)
    }
    
    // TODO: Finish This
    
    public func hasOne<T: Model>(table: T.Type, foreignKey: String? = nil) -> T? {
        let q = Query<T>()
        let fkey = foreignKey ?? "\(Self.entity)_id"
        return q.with(fkey, .Equals, id!).first()
    }
    
    public func hasMany<T: Model>(table: T.Type, foreignKey: String? = nil) -> [T]? {
        let q = Query<T>()
        let fkey = foreignKey ?? "\(Self.entity)_id"
        return q.with(fkey, .Equals, id!).all()
    }
    
    public func belongsTo<T: Model>(table: T.Type, foreignKey: String? = nil, otherKey: String? = nil) -> T? {
        let q = Query<T>()
        let fkey = foreignKey ?? "\(table.entity)_id"
        let other = otherKey ?? "id"
        return q.with(other, .Equals, fkey).first()
    }
    
//    public func belongsToMany<T: Model>(table: T.Type, intermediateTableName: String? = nil, foreignKey1: String? = nil, foreignKey2: String? = nil) -> [T]? {
//        return Query().joins([table])
//    }

//    public func hasManyThrough<T: Model, U: Model>(table1: T.Type, table2: U.Type, foreignKey1: String? = nil, foreignKey2: String? = nil) -> [T]? {
//        return nil
//    }
    
    public static func find(ids: Value...) -> [Self]? {
        return Query()._with("id", .In, ids).all()
    }
    
    public static func findOne(id: Value) -> Self? {
        return Query().with("id", .Equals, id).first()
    }
    
    public static func findWith(key: String, _ op: Operator, _ values: Value...) -> [Self]? {
        return Query()._with(key, op, values).all()
    }
    
    public static func take(count: Int = 1) -> [Self]? {
        return Query().limit(count).all()
    }
    
    public static func first(count: Int = 1) -> Self? {
        return Query().orderBy("id", .Ascending).limit(count).first()
    }
    
    public static func last(count: Int = 1) -> Self? {
        return Query().orderBy("id", .Descending).limit(count).first()
    }
    
//    public static func list(key: String) -> [String]? {
//        return Query().list(key)
//    }
//
//    public static func exist() -> Bool {
//        return self.count > 0
//    }
//
//    public static var count: Int {
//        return Query().count()
//    }
//    
//    public static func average(key: String = "*") -> Double {
//        return Query().avg(key)
//    }
//    
//    public static func maximum(key: String = "*") -> Double {
//        return Query().max(key)
//    }
//    
//    public static func minimum(key: String = "*") -> Double {
//        return Query().min(key)
//    }
//    
//    public static func sum(key: String = "*") -> Double {
//        return Query().sum(key)
//    }
}
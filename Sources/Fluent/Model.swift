
public protocol Model {
    static var entity: String { get }
    var id: String? { get }
    
    func serialize() -> [String: Value?]
    init(serialized: [String: Value])
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

    public static func all() -> [Self] {
        return Query().all()
    }
    
    public static func find(ids: Value...) -> [Self]? {
        return Query().filter("id", in: ids).all()
    }
    
    public static func find(id: Value) -> Self? {
        return Query().filter("id", .Equals, id).first()
    }
    
    public static func find(field: String, _ comparison: Filter.Comparison, _ value: Value) -> [Self]? {
        return Query().filter(field, comparison, value).all()
    }
    
    public static func find(field: String, in value: [Value]) -> [Self]? {
        return Query().filter(field, in: value).all()
    }
    
    public static func take(count: Int = 1) -> [Self]? {
        return Query().limit(count).all()
    }
    
    public static func first(count: Int = 1) -> Self? {
        return Query().sort("id", .Ascending).limit(count).first()
    }
    
    public static func last(count: Int = 1) -> Self? {
        return Query().sort("id", .Descending).limit(count).first()
    }
}
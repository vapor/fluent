public protocol QueryFilter {
    associatedtype Field
    
    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype Method: QueryFilterMethod
    
    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype Value: QueryFilterValue
    
    associatedtype Relation: QueryFilterRelation
    
    static func unit(_ field: Field, _ method: Method, _ value: Value) -> Self
    static func group(_ relation: Relation, _ filters: [Self]) -> Self
}

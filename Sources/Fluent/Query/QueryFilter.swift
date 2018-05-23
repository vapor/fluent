public protocol QueryFilter {
    associatedtype Field: PropertySupporting
    
    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype Method: QueryFilterMethod
    
    /// Custom filter type. Supported by `Query.Filter.Method`.
    associatedtype Value: QueryFilterValue
    
    associatedtype Relation: QueryFilterRelation
    
    static func fluentFilter(_ field: Field, _ method: Method, _ value: Value) -> Self
    static func fluentFilterGroup(_ relation: Relation, _ filters: [Self]) -> Self
}

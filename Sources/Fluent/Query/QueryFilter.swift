/// Supports `QueryBuilder` filter methods.
public protocol QueryFilter {
    /// Associated field type. Created from key paths, coding keys, or reflected properties.
    associatedtype Field: PropertySupporting
    
    /// Associated filter method. i.e., equals, not equals, greater than, etc.
    associatedtype Method: QueryFilterMethod
    
    /// Associated filter value. Usually the number of binds for this filter alongside special nil cases.
    associatedtype Value: QueryFilterValue

    /// Associated filter group relation type. Describes how filters can be related.
    associatedtype Relation: QueryFilterRelation

    /// Creates an instance of self from a field method and value.
    ///
    /// - parameters:
    ///     - field: Field to filter.
    ///     - method: Method to compare field and value.
    ///     - value: Value type.
    static func fluentFilter(_ field: Field, _ method: Method, _ value: Value) -> Self

    /// Creates an instance of self from a relation and an array of other filters.
    ///
    /// - parameters:
    ///     - relation: How to relate the grouped filters.
    ///     - filters: An array of filters to group.
    static func fluentFilterGroup(_ relation: Relation, _ filters: [Self]) -> Self
}

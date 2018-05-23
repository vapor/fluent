public protocol QuerySort {
    associatedtype Field: PropertySupporting
    associatedtype Direction: QuerySortDirection
    static func fluentSort(_ field: Field, _ direction: Direction) -> Self
}

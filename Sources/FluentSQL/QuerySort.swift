extension DatabaseQuery.Sort where Database: QuerySupporting, Database.QueryField: DataColumnRepresentable {
    /// Convert query sort to sql order by.
    internal func makeDataOrderBy() -> DataOrderBy {
        return DataOrderBy(
            columns: [field.makeDataColumn()],
            direction: direction.makeOrderByDirection()
        )
    }
}

extension DatabaseQuery.Sort.Direction {
    /// Convert query sort direction to sql order by direction.
    internal func makeOrderByDirection() -> DataOrderByDirection {
        switch self {
        case .ascending: return .ascending
        case .descending: return .descending
        }
    }
}

extension DataOrderBy: QuerySort {
    public static func fluentSort(_ field: DataColumn, _ direction: DataOrderByDirection) -> DataOrderBy {
        return .init(columns: [field], direction: direction)
    }

    public typealias Field = DataColumn
    public typealias Direction = DataOrderByDirection

    public func convertToDataOrderBy() -> DataOrderBy {
        return self
    }
}

extension DataOrderByDirection: QuerySortDirection {
    public static var fluentAscending: DataOrderByDirection {
        return .ascending
    }

    public static var fluentDescending: DataOrderByDirection {
        return .descending
    }
}

extension QueryAggregate {
    /// Convert query aggregate to sql computed field.
    internal func makeDataComputed() -> DataComputedColumn {
        return .init(
            function: method.makeDataComputedFunction(),
            columns: field.flatMap { [ $0.makeDataColumn() ] } ?? []
        )
    }
}

extension QueryAggregateMethod {
    /// Convert query aggregate method to computed function name.
    internal func makeDataComputedFunction() -> String {
        switch self {
        case .count: return "count"
        case .sum: return "sum"
        case .average: return "avg"
        case .min: return "min"
        case .max: return "max"
        }
    }
}

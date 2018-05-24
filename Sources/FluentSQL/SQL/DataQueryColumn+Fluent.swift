extension DataManipulationKey: QueryKey {
    public typealias AggregateMethod = String

    public static func fluentProperty(_ property: QueryProperty) -> DataManipulationKey {
        return .column(.fluentProperty(property), key: nil)
    }

    public typealias Field = DataColumn

    public static var fluentAll: DataManipulationKey {
        return .all
    }

    public static func fluentAggregate(_ function: String, _ keys: [DataManipulationKey]) -> DataManipulationKey {
        return .computed(.init(function: function, keys: keys), key: "fluentAggregate")
    }
}

extension String: QueryAggregateMethod {
    public static var fluentCount: String {
        return "COUNT"
    }

    public static var fluentSum: String {
        return "SUM"
    }

    public static var fluentAverage: String {
        return "AVERAGE"
    }

    public static var fluentMinimum: String {
        return "MIN"
    }

    public static var fluentMaximum: String {
        return "MAX"
    }
}

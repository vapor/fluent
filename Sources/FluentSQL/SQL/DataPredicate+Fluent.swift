extension DataPredicateItem: QueryFilter {
    public typealias Field = DataColumn
    public typealias Method = DataPredicateComparison
    public typealias Value = DataManipulationValue
    public typealias Relation = DataPredicateGroupRelation
    public static func fluentFilter(_ field: DataColumn, _ method: DataPredicateComparison, _ value: DataManipulationValue) -> DataPredicateItem {
        return .predicate(.init(column: field, comparison: method, value: value))
    }

    public static func fluentFilterGroup(_ relation: DataPredicateGroupRelation, _ filters: [DataPredicateItem]) -> DataPredicateItem {
        return .group(.init(relation: relation, predicates: filters))
    }

    public func convertToDataPredicateItem() -> DataPredicateItem {
        return self
    }
}

extension DataPredicateComparison: QueryFilterMethod {
    public static var fluentEqual: DataPredicateComparison { return .equal }
    public static var fluentNotEqual: DataPredicateComparison { return .notEqual }
    public static var fluentGreaterThan: DataPredicateComparison { return .greaterThan }
    public static var fluentLessThan: DataPredicateComparison { return .lessThan }
    public static var fluentGreaterThanOrEqual: DataPredicateComparison { return .greaterThanOrEqual}
    public static var fluentLessThanOrEqual: DataPredicateComparison { return .lessThanOrEqual }
    public static var fluentInSubset: DataPredicateComparison { return .in }
    public static var fluentNotInSubset: DataPredicateComparison { return .notIn }
}

extension DataManipulationValue: QueryFilterValue {
    public static func fluentEncodables(_ encodables: [Encodable]) -> DataManipulationValue {
        return .values(encodables)
    }

    public static var fluentNil: DataManipulationValue {
        return .null
    }

    public static func fluentProperty(_ property: QueryProperty) -> DataManipulationValue {
        return .column(.fluentProperty(property))
    }
}

extension DataPredicateGroupRelation: QueryFilterRelation {
    public static var fluentAnd: DataPredicateGroupRelation { return .and }
    public static var fluentOr: DataPredicateGroupRelation { return .or }
}

extension DataManipulationQuery: Query {
    /// See `Query`.
    public typealias Data = [DataManipulationColumn]

    /// See `Query`.
    public typealias Action = DataManipulationStatement

    /// See `Query`.
    public typealias Filter = DataPredicateItem

    /// See `Query`.
    public typealias Key = DataManipulationKey

    /// See `Query`.
    public typealias Range = DataLimitOffset

    /// See `Query`.
    public typealias Sort = DataOrderBy

    /// See `Query`.
    public static func fluentQuery(_ table: String) -> DataManipulationQuery {
        return .init(statement: .select(), table: table)
    }

    /// See `Query`.
    public var fluentAction: DataManipulationStatement {
        get { return statement }
        set { statement = newValue}
    }

    /// See `Query`.
    public var fluentData: [DataManipulationColumn] {
        get { return columns }
        set { columns = newValue }
    }

    /// See `Query`.
    public var fluentFilters: [DataPredicateItem] {
        get { return predicates }
        set { predicates = newValue }
    }

    /// See `Query`.
    public var fluentKeys: [DataManipulationKey] {
        get { return keys }
        set { keys = newValue }
    }

    /// See `Query`.
    public var fluentRange: DataLimitOffset? {
        get {
            switch (limit, offset) {
            case (.some(let limit), .some(let offset)):
                return .init(offset: offset, limit: limit)
            case (.none, .some(let offset)):
                return .init(offset: offset, limit: nil)
            default: return nil
            }
        }
        set {
            if let first = newValue {
                limit = first.limit
                offset = first.offset
            } else {
                limit = nil
                offset = nil
            }
        }
    }

    /// See `Query`.
    public var fluentSorts: [DataOrderBy] {
        get { return orderBys }
        set { orderBys = newValue }
    }

    /// See `Query`.
    public var fluentGroupBys: [DataGroupBy] {
        get{ return groupBys }
        set { groupBys = newValue }
    }
}

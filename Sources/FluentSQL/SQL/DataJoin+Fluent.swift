extension DataJoin: QueryJoin {
    public typealias Field = DataColumn
    public typealias Method = DataJoinMethod

    public static func fluentJoin(_ method: DataJoinMethod, base: DataColumn, joined: DataColumn) -> DataJoin {
        return .init(method: method, local: base, foreign: joined)
    }
}

extension DataJoinMethod: QueryJoinMethod {
    public static var `default`: DataJoinMethod {
        return .inner
    }
}

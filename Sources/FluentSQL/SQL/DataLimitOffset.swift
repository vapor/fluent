public struct DataLimitOffset: QueryRange {
    public static func fluentRange(lower: Int, upper: Int?) -> DataLimitOffset {
        if let upper = upper {
            return .init(offset: lower, limit: upper - lower)
        } else {
            return .init(offset: lower, limit: nil)
        }

    }

    public var offset: Int
    public var limit: Int?
}

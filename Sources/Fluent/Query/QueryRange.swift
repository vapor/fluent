/// Fluent's supported range type.
public protocol QueryRange {
    /// Creates a new limit with a count and offset.
    ///
    /// - parameters:
    ///     - lower: Amount to offset the query by.
    ///     - upper: `upper` - `lower` = maximum results.
    static func fluentRange(lower: Int, upper: Int?) -> Self
}

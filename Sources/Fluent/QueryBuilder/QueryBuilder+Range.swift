extension QueryBuilder {
    // MARK: Range

    /// Limits the results of this query to the specified range.
    ///
    ///     query.range(2..<5) // returns at most 3 results, offset by 2
    ///
    /// - returns: Query builder for chaining.
    public func range(_ range: Range<Int>) -> Self {
        return self.range(lower: range.lowerBound, upper: range.upperBound)
    }

    /// Limits the results of this query to the specified range.
    ///
    ///     query.range(...5) // returns at most 6 results
    ///
    /// - returns: Query builder for chaining.
    public func range(_ range: PartialRangeThrough<Int>) -> Self {
        return self.range(upper: range.upperBound)
    }

    /// Limits the results of this query to the specified range.
    ///
    ///     query.range(..<5) // returns at most 5 results
    ///
    /// - returns: Query builder for chaining.
    public func range(_ range: PartialRangeUpTo<Int>) -> Self {
        return self.range(upper: range.upperBound - 1)
    }

    /// Limits the results of this query to the specified range.
    ///
    ///     query.range(5...) // offsets the result by 5
    ///
    /// - returns: Query builder for chaining.
    public func range(_ range: PartialRangeFrom<Int>) -> Self {
        return self.range(lower: range.lowerBound)
    }

    /// Limits the results of this query to the specified range.
    ///
    ///     query.range(2..<5) // returns at most 3 results, offset by 2
    ///
    /// - returns: Query builder for chaining.
    public func range(_ range: ClosedRange<Int>) -> Self {
        return self.range(lower: range.lowerBound, upper: range.upperBound)
    }

    /// Limits the results of this query to the specified range.
    ///
    /// - parameters:
    ///     - lower: Amount to offset the query by.
    ///     - upper: `upper` - `lower` = maximum results.
    /// - returns: Query builder for chaining.
    public func range(lower: Int = 0, upper: Int? = nil) -> Self {
        Database.queryRangeApply(lower: lower, upper: upper, to: &query)
        return self
    }
}

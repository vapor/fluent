extension Query {
    // MARK: Range

    /// Defines a Fluent query limit and offset.
    public struct Range {
        /// The lower bound of item indexes to return. This should be `0` by default.
        public var lower: Int

        /// The upper bound of item indexes to return. If this is `nil`, the range acts as just on offset.
        /// If it is set, the number of results will have a max possible value (upper - lower).
        public var upper: Int?

        /// Creates a new limit with a count and offset.
        ///
        /// - parameters:
        ///     - lower: Amount to offset the query by.
        ///     - upper: `upper` - `lower` = maximum results.
        public init(lower: Int, upper: Int?) {
            self.lower = lower
            self.upper = upper
        }
    }
}

extension Query.Builder {
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
        return addRange(.init(lower: lower, upper: upper))
    }

    /// Adds a custom `Query.Range` to the query builder.
    ///
    /// - parameters:
    ///     - range: New range to add.
    /// - returns: Query builder for chaining.
    public func addRange(_ range: Query.Range) -> Self {
        query.range = range
        return self
    }
}

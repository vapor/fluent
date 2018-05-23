/// Aggregates generate data for every row of returned data. They usually aggregate data for a single field,
/// but can also operate over most fields. When an aggregate is applied to a query, the aggregate method will apply
/// to all rows filtered by the query, but only one row (the aggregate) will actually be returned.
///
/// The most common use of aggregates is to get the count of columns.
///
///     let count = User.query(on: ...).count()
///
/// They can also be used to generate sums or averages for all values in a column.
public enum QueryAggregateMethod {
    /// Counts the number of matching entities.
    case count
    /// Adds all values of the chosen field.
    case sum
    /// Averges all values of the chosen field.
    case average
    /// Returns the minimum value for the chosen field.
    case min
    /// Returns the maximum value for the chosen field.
    case max
}

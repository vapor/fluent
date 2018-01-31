import CodableKit

/// Describes the methods for comparing
/// a field to a set of values.
/// Think of it like Swift's `.contains`.
public enum QuerySubsetScope {
    case `in`
    case notIn
}

/// Describes the values a subset can have.
/// The subset can be either an array of encodable
/// values or another query whose purpose
/// is to yield an array of values.
public enum QuerySubsetValue<Database> where Database: QuerySupporting {
    case array([Encodable])
    case subquery(DatabaseQuery<Database>)
}

extension QueryBuilder {
    /// Subset `in` filter.
    @discardableResult
    public func filter<T>(
        _ field: ReferenceWritableKeyPath<Model, T>,
        in values: [Encodable]
    ) -> Self where T: KeyStringDecodable {
        let filter = QueryFilter<Model.Database>(
            entity: Model.entity,
            method: .subset(field.makeQueryField(), .in, .array(values))
        )
        return addFilter(filter)
    }

    /// Subset `notIn` filter.
    @discardableResult
    public func filter<T>(
        _ field: ReferenceWritableKeyPath<Model, T>,
        notIn values: [Encodable]
    ) -> Self where T: KeyStringDecodable {
        let filter = QueryFilter<Model.Database>(
            entity: Model.entity,
            method: .subset(field.makeQueryField(), .notIn, .array(values))
        )
        return addFilter(filter)
    }
}

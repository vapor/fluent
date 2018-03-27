extension QueryBuilder {
    /// Applies a filter from one of the filter operators (==, !=, etc)
    /// note: this method is generic, allowing you to omit type names
    /// when filtering using key paths.
    @discardableResult
    public func filter(_ value: ModelFilter<Model>) -> Self {
        return addFilter(.single(value.filter))
    }

    /// Applies a filter from one of the filter operators (==, !=, etc)
    /// note: this method is generic, allowing you to omit type names
    /// when filtering using key paths.
    @discardableResult
    public func filter<M>(_ joined: M.Type, _ value: ModelFilter<M>) -> Self
        where M.Database == Model.Database
    {
        return addFilter(.single(value.filter))
    }
}

/// Typed wrapper around query filter methods.
public struct ModelFilter<M> where M: Model, M.Database: QuerySupporting {
    /// The wrapped query filter method.
    public let filter: QueryFilter<M.Database>

    /// Creates a new model filter method.
    public init(filter: QueryFilter<M.Database>) {
        self.filter = filter
    }
}

/// Model.field == value
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> {
    return try _compare(lhs, .equals, .data(rhs))
}
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> {
    return try _compare(lhs, .equals, .data(rhs))
}

/// Model.field != value
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> {
    return try _compare(lhs, .notEquals, .data(rhs))
}
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> {
    return try _compare(lhs, .notEquals, .data(rhs))
}

/// Model.field > value
public func > <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> {
    return try _compare(lhs, .greaterThan, .data(rhs))
}
public func > <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> {
    return try _compare(lhs, .greaterThan, .data(rhs))
}

/// Model.field < value
public func < <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> {
    return try _compare(lhs, .lessThan, .data(rhs))
}
public func < <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> {
    return try _compare(lhs, .lessThan, .data(rhs))
}

/// Model.field >= value
public func >= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> {
    return try _compare(lhs, .greaterThanOrEquals, .data(rhs))
}
public func >= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> {
    return try _compare(lhs, .greaterThanOrEquals, .data(rhs))
}

/// Model.field <= value
public func <= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> {
    return try _compare(lhs, .lessThanOrEquals,  .data(rhs))
}
public func <= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> {
    return try _compare(lhs, .lessThanOrEquals, .data(rhs))
}

infix operator ~~
infix operator !~

/// Subset: IN.
public func ~~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: [Value]) throws -> ModelFilter<Model> {
    return try _compare(lhs, .in, .array(rhs))
}

/// Subset: NOT IN.
public func !~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: [Value]) throws -> ModelFilter<Model> {
    return try _compare(lhs, .notIn, .array(rhs))
}

/// Operator helper func.
private func _compare<M, V>(
    _ key: KeyPath<M, V>,
    _ type: QueryFilterType<M.Database>,
    _ value: QueryFilterValue<M.Database>
) throws -> ModelFilter<M> {
    let filter = try QueryFilter(field: key.makeQueryField(), type: type, value: value)
    return ModelFilter<M>(filter: filter)
}

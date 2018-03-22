import CodableKit

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
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .equals, value: rhs)
}
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .equals, value: rhs)
}

/// Model.field != value
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .notEquals, value: rhs)
}
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .notEquals, value: rhs)
}

/// Model.field > value
public func > <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .greaterThan, value: rhs)
}
public func > <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .greaterThan, value: rhs)
}

/// Model.field < value
public func < <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .lessThan, value: rhs)
}
public func < <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .lessThan, value: rhs)
}

/// Model.field >= value
public func >= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .greaterThanOrEquals, value: rhs)
}
public func >= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .greaterThanOrEquals, value: rhs)
}

/// Model.field <= value
public func <= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .lessThanOrEquals, value: rhs)
}
public func <= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value?) throws -> ModelFilter<Model> where Value: KeyStringDecodable {
    return try _compare(lhs, .lessThanOrEquals, value: rhs)
}

/// Operator helper func.
private func _compare<M, V>(_ key: KeyPath<M, V>, _ type: QueryFilterType<M.Database>, value: V?) throws -> ModelFilter<M>
    where V: KeyStringDecodable
{
    let filter = try QueryFilter(field: key.makeQueryField(), type: type, value: .data(value))
    return ModelFilter<M>(filter: filter)
}

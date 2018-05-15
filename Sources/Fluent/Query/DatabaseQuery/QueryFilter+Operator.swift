extension QueryBuilder {
    /// Applies a filter from one of the filter operators (==, !=, etc).
    ///
    ///     let users = try User.query(on: conn).filter(\.name == "Vapor").all()
    ///
    /// - note: This method is generic, allowing you to omit type names
    ///         when filtering using key paths.
    @discardableResult
    public func filter(_ value: OperatorFilter<Model>) -> Self {
        return addFilter(.single(value.filter))
    }

    /// Applies a filter from one of the filter operators (==, !=, etc) to a joined model.
    ///
    ///     let usersWithCats = try User.query(on: conn)
    ///         .join(Pet.self, ...)
    ///         .filter(Pet.self, \.type == .cat)
    ///         .all()
    ///
    /// - note: This method is generic, allowing you to omit type names
    ///         when filtering using key paths.
    @discardableResult
    public func filter<M>(_ joined: M.Type, _ value: OperatorFilter<M>) -> Self
        where M.Database == Model.Database
    {
        return addFilter(.single(value.filter))
    }
}

/// Typed wrapper around query filter methods.
///
///     let users = try User.query(on: conn).filter(\.name == "Vapor").all()
///
/// Used with the `filter(...)` overload that accepts typed operators.
public struct OperatorFilter<M> where M: Model, M.Database: QuerySupporting {
    /// The wrapped query filter method.
    public let filter: DatabaseQuery<M.Database>.FilterItem

    /// Creates a new `OperatorFilter`.
    public init(filter: DatabaseQuery<M.Database>.FilterItem) {
        self.filter = filter
    }
}

/// Applies an equality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.name == "Vapor").all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .equals, .data(rhs))
}

/// Applies an inverse equality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.name != "Vapor").all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .notEquals, .data(rhs))
}

/// Applies a greater than inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age > 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func > <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .greaterThan, .data(rhs))
}

/// Applies a less than inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age < 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func < <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .lessThan, .data(rhs))
}

/// Applies a greater than or equal inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age >= 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func >= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .greaterThanOrEquals, .data(rhs))
}

/// Applies a less than or equal inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age <= 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func <= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .lessThanOrEquals,  .data(rhs))
}

infix operator ~~
infix operator !~

/// Applies a subset filter to the query. Only fields whose values are
/// included in the supplied array will be returned.
///
///     let users = try User.query(on: conn).filter(\.luckyNumber ~~ [5, 7, 11]).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func ~~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: [Value]) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .in, .array(rhs))
}

/// Applies an inverse subset filter to the query. Only fields whose values are _not_
/// included in the supplied array will be returned.
///
///     let users = try User.query(on: conn).filter(\.luckyNumber !~ [5, 7, 11]).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func !~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: [Value]) throws -> OperatorFilter<Model> {
    return try _compare(lhs, .notIn, .array(rhs))
}

/// Operator helper func.
private func _compare<M, V>(_ key: KeyPath<M, V>, _ type: DatabaseQuery<M.Database>.FilterType, _ value: DatabaseQuery<M.Database>.FilterValue) throws -> OperatorFilter<M> {
    let filter = try DatabaseQuery<M.Database>.FilterItem(field: M.Database.queryField(for: key), type: type, value: value)
    return OperatorFilter<M>(filter: filter)
}

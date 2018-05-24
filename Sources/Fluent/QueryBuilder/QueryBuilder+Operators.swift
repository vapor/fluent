extension QueryBuilder {
    /// Applies a filter from one of the filter operators (==, !=, etc).
    ///
    ///     let users = try User.query(on: conn).filter(\.name == "Vapor").all()
    ///
    /// - note: This method is generic, allowing you to omit type names
    ///         when filtering using key paths.
    @discardableResult
    public func filter(_ value: FilterOperator<Model>) -> Self {
        return filter(value.filter)
    }

    /// Applies a filter from one of the filter operators (==, !=, etc) to a joined model.
    ///
    ///     let usersWithCats = try User.query(on: conn)
    ///         .join(Pet.self, ...)
    ///         .filter(\Pet.type == .cat)
    ///         .all()
    ///
    /// - note: This method is generic, allowing you to omit type names
    ///         when filtering using key paths.
    @discardableResult
    public func filter<A>(_ value: FilterOperator<A>) -> Self
        where A.Database == Model.Database
    {
        return filter(value.filter)
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
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentEqual, [rhs])
}

/// Applies an inverse equality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.name != "Vapor").all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentNotEqual, [rhs])
}

/// Applies a greater than inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age > 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func > <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentGreaterThan, [rhs])
}

/// Applies a less than inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age < 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func < <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentLessThan, [rhs])
}

/// Applies a greater than or equal inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age >= 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func >= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentGreaterThanOrEqual, [rhs])
}

/// Applies a less than or equal inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age <= 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func <= <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentLessThanOrEqual, [rhs])
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
public func ~~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: [Value]) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentInSubset, rhs)
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
public func !~ <Model, Value>(lhs: KeyPath<Model, Value>, rhs: [Value]) -> FilterOperator<Model> where Value: Encodable {
    return .make(lhs, .fluentNotInSubset, rhs)
}

/// Typed wrapper around query filter methods.
///
///     let users = try User.query(on: conn).filter(\.name == "Vapor").all()
///
/// Used with the `filter(...)` overload that accepts typed operators.
public struct FilterOperator<Model> where Model: Fluent.Model, Model.Database: QuerySupporting {
    /// The wrapped query filter method.
    fileprivate let filter: Model.Database.Query.Filter

    /// Operator helper func.
    public static func make<V>(_ key: KeyPath<Model, V>, _ method: Model.Database.Query.Filter.Method, _ values: [V]) -> FilterOperator<Model>
        where V: Encodable
    {
        if values.count == 1 && values[0].isNil {
            return FilterOperator<Model>(filter: .fluentFilter(.keyPath(key), method, .fluentNil))
        } else {
            return FilterOperator<Model>(filter: .fluentFilter(.keyPath(key), method, .fluentEncodables(values)))
        }
    }
}

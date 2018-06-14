extension QueryBuilder {
    /// Applies a filter from one of the filter operators (==, !=, etc).
    ///
    ///     let users = try User.query(on: conn).filter(\.name == "Vapor").all()
    ///
    /// - note: This method is generic, allowing you to omit type names
    ///         when filtering using key paths.
    @discardableResult
    public func filter(_ value: FilterOperator<Database, Result>) -> Self {
        return filter(value.filter)
    }

    /// Applies a filter from one of the filter operators (==, !=, etc) to a joined model.
    ///
    ///     let usersWithCats = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(\Pet.type == .cat)
    ///         .all()
    ///
    /// - note: This method is generic, allowing you to omit type names
    ///         when filtering using key paths.
    @discardableResult
    public func filter<A>(_ value: FilterOperator<Database, A>) -> Self {
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
public func == <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: Value) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodEqual, [rhs])
}

/// Applies an inverse equality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.name != "Vapor").all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func != <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: Value) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodNotEqual, [rhs])
}

/// Applies a greater than inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age > 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func > <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: Value) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodGreaterThan, [rhs])
}

/// Applies a less than inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age < 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func < <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: Value) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodLessThan, [rhs])
}

/// Applies a greater than or equal inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age >= 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func >= <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: Value) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodGreaterThanOrEqual, [rhs])
}

/// Applies a less than or equal inequality filter to the query.
///
///     let users = try User.query(on: conn).filter(\.age <= 18).all()
///
/// - parameters:
///     - lhs: Field being filtered.
///     - rhs: Value to filter the field by.
/// - returns: An `OperatorFilter` suitable for passing into `filter(...)`.
public func <= <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: Value) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodLessThanOrEqual, [rhs])
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
public func ~~ <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: [Value]) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodInSubset, rhs)
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
public func !~ <Database, Result, Value>(lhs: KeyPath<Result, Value>, rhs: [Value]) -> FilterOperator<Database, Result> where Value: Encodable {
    return .make(lhs, Database.queryFilterMethodNotInSubset, rhs)
}

/// Typed wrapper around query filter methods.
///
///     let users = try User.query(on: conn).filter(\.name == "Vapor").all()
///
/// Used with the `filter(...)` overload that accepts typed operators.
public struct FilterOperator<Database, Result> where Database: QuerySupporting {
    /// The wrapped query filter method.
    fileprivate let filter: Database.QueryFilter

    /// Operator helper func.
    public static func make<V>(_ key: KeyPath<Result, V>, _ method: Database.QueryFilterMethod, _ values: [V]) -> FilterOperator<Database, Result>
        where V: Encodable
    {
        if values.count == 1 && values[0].isNil {
            return FilterOperator<Database, Result>(
                filter: Database.queryFilter(Database.queryField(.keyPath(key)), method, Database.queryFilterValueNil)
            )
        } else {
            return FilterOperator<Database, Result>(
                filter: Database.queryFilter(Database.queryField(.keyPath(key)), method, Database.queryFilterValue(values))
            )
        }
    }
}

extension JoinSupporting where
    QueryJoin: SQLJoin,
    QueryJoinMethod == QueryJoin.Method,
    QueryJoin.Expression.ColumnIdentifier.TableIdentifier == QueryJoin.TableIdentifier
{
    /// See `JoinSupporting`.
    public static func queryJoin(_ method: QueryJoinMethod, base: QueryJoin.Expression.ColumnIdentifier, joined: QueryJoin.Expression.ColumnIdentifier) -> QueryJoin {
        guard let table = joined.table else {
            fatalError("Cannot join column without a table identifier: \(joined).")
        }
        return .join(method, table, .binary(.column(base), .equal, .column(joined)))
    }
}

extension JoinSupporting where QueryJoinMethod: SQLJoinMethod {
    /// See `JoinSupporting`.
    public static var queryJoinMethodDefault: QueryJoinMethod {
        return .default
    }
}

extension JoinSupporting where Query: FluentSQLQuery, QueryJoin == Query.Join {
    /// See `JoinSupporting`.
    public static func queryJoinApply(_ join: QueryJoin, to query: inout Query) {
        query.joins.append(join)
    }
}

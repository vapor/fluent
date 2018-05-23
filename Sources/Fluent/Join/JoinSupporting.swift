/// A database that supports `join(...)` methods on `QueryBuilder`.
public protocol JoinSupporting: QuerySupporting where Query: JoinsContaining { }

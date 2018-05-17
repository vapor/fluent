/// Supports `join(...)` methods on `Query.Builder`.
public protocol JoinSupporting: QuerySupporting
    where Query: JoinsContaining { }

public protocol JoinsContaining: Query {
    associatedtype Join: QueryJoin
        where Join.Field == Field
    var fluentJoins: [Join] { get set }
}

public protocol QueryJoin {
    associatedtype Field
    associatedtype Method: QueryJoinMethod
    static func fluentJoin(_ method: Method, base: Field, joined: Field) -> Self
}

public protocol QueryJoinMethod {
    static var `default`: Self { get }
}

extension QueryBuilder where Model.Database: JoinSupporting {
    // MARK: Join

    /// Joins another model to this query builder. You can filter your existing query by joined models.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(\Pet.type == .cat)
    ///         .all()
    ///     print(users) // Future<[User]>
    ///
    /// You can also decode their entities from the result set.
    ///
    ///     let usersAndPets = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(Pet.self, \.type == .cat)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(usersAndPets) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - joinedType: Foreign model to join to this query.
    ///     - joinedKey: Field on the foreign model to join.
    ///     - baseKey: Field on the current model to join.
    ///                This should be the model you used to create this query builder.
    ///     - method: Join method to use, inner by default.
    public func join<A, B, C>(_ joinedKey: KeyPath<A, C>, to baseKey: KeyPath<B, C>, method: Model.Database.Query.Join.Method = .default) -> Self
        where A: Fluent.Model, B: Fluent.Model, A.Database == B.Database, A.Database == Model.Database
    {
        query.fluentJoins.append(.fluentJoin(method, base: .keyPath(baseKey), joined: .keyPath(joinedKey)))
        return self
    }

    /// Joins another model to this query builder. You can filter your existing query by joined models.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(Pet.self, \.type == .cat)
    ///         .all()
    ///     print(users) // Future<[User]>
    ///
    /// You can also decode their entities from the result set.
    ///
    ///     let usersAndPets = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(Pet.self, \.type == .cat)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(usersAndPets) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - joinedType: Foreign model to join to this query.
    ///     - joinedKey: Field on the foreign model to join.
    ///     - baseKey: Field on the current model to join.
    ///                This should be the model you used to create this query builder.
    ///     - method: Join method to use, inner by default.
    public func join<A, B, C>(_ joinedKey: KeyPath<A, C>, to baseKey: KeyPath<B, C?>, method: Model.Database.Query.Join.Method = .default) -> Self
        where A: Fluent.Model, B: Fluent.Model, A.Database == B.Database, A.Database == Model.Database
    {
        query.fluentJoins.append(.fluentJoin(method, base: .keyPath(baseKey), joined: .keyPath(joinedKey)))
        return self
    }

    /// Joins another model to this query builder. You can filter your existing query by joined models.
    ///
    ///     let users = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(Pet.self, \.type == .cat)
    ///         .all()
    ///     print(users) // Future<[User]>
    ///
    /// You can also decode their entities from the result set.
    ///
    ///     let usersAndPets = try User.query(on: conn)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .filter(Pet.self, \.type == .cat)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(usersAndPets) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - joinedType: Foreign model to join to this query.
    ///     - joinedKey: Field on the foreign model to join.
    ///     - baseKey: Field on the current model to join.
    ///                This should be the model you used to create this query builder.
    ///     - method: Join method to use, inner by default.
    public func join<A, B, C>(_ joinedKey: KeyPath<A, C?>, to baseKey: KeyPath<B, C>, method: Model.Database.Query.Join.Method = .default) -> Self
        where A: Fluent.Model, B: Fluent.Model, A.Database == B.Database, A.Database == Model.Database
    {
        query.fluentJoins.append(.fluentJoin(method, base: .keyPath(baseKey), joined: .keyPath(joinedKey)))
        return self
    }
}

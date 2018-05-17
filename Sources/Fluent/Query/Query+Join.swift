extension Query {
    // MARK: Join

    /// Describes a relational join which brings columns of data from multiple entities into one response.
    ///
    /// A = (id, name, b_id)
    /// B = (id, foo)
    ///
    /// A join B = (id, b_id, name, foo)
    ///
    /// joinedKey = A.b_id
    /// baseKey = B.id
    public struct Join {
        /// An exhaustive list of possible join types.
        public enum Method {
            /// returns only rows that appear in both sets
            case inner
            /// returns all matching rows from the queried table _and_ all rows that appear in both sets
            case outer
        }

        /// Join type.
        public let method: Method

        /// Table/collection that will be accepting the joined data
        ///
        /// The key from the base table that will be compared to the key from the joined table during the join.
        ///
        /// base        | joined
        /// ------------+-------
        /// <baseKey>   | base_id
        public let base: Field

        /// table/collection that will be joining the base data
        ///
        /// The key from the joined table that will be compared to the key from the base table during the join.
        ///
        /// base | joined
        /// -----+-------
        /// id   | <joined_key>
        public let joined: Field

        /// Create a new Join
        public init(method: Method, base: Field, joined: Field) {
            self.method = method
            self.base = base
            self.joined = joined
        }
    }
}

extension Query.Builder {
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
    public func join<A, B, C>(_ joinedKey: KeyPath<A, C>, to baseKey: KeyPath<B, C>, method: Query.Join.Method = .inner) -> Self
        where A: Fluent.Model, B: Fluent.Model, A.Database == B.Database, A.Database == Database, Database: JoinSupporting
    {
        query.joins.append(.init(method: method, base: .keyPath(baseKey), joined: .keyPath(joinedKey)))
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
    public func join<A, B, C>(_ joinedKey: KeyPath<A, C>, to baseKey: KeyPath<B, C?>, method: Query.Join.Method = .inner) -> Self
        where A: Fluent.Model, B: Fluent.Model, A.Database == B.Database, A.Database == Database, Database: JoinSupporting
    {
        query.joins.append(.init(method: method, base: .keyPath(baseKey), joined: .keyPath(joinedKey)))
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
    public func join<A, B, C>(_ joinedKey: KeyPath<A, C?>, to baseKey: KeyPath<B, C>, method: Query.Join.Method = .inner) -> Self
        where A: Fluent.Model, B: Fluent.Model, A.Database == B.Database, A.Database == Database, Database: JoinSupporting
    {
        query.joins.append(.init(method: method, base: .keyPath(baseKey), joined: .keyPath(joinedKey)))
        return self
    }
}

/// Describes a relational join which brings
/// columns of data from multiplies entities
/// into one response.
///
/// A = (id, name, b_id)
/// B = (id, foo)
///
/// A join B = (id, b_id, name, foo)
///
/// foreignKey = A.b_id
/// localKey = B.id
public struct Join {
    /// Entity that will be accepting
    /// the joined data
    let local: Entity.Type

    /// Entity that will be joining
    /// the local data
    let foreign: Entity.Type

    /// Foreign entity key that is local
    /// to the entity it resides on
    ///
    /// "Foreign" keys point to this id.
    ///
    /// ex: "id"
    let localKey: String

    /// Foreign entity key that is foreign
    /// to the entity it resides on
    ///
    /// This id is a pointer to "Local" keys
    ///
    /// ex: "foo_id"
    let foreignKey: String

    /// Create a new Join using a Local and Foreign
    /// entity.
    /// 
    /// See Join.localKey and Join.foreignKey
    /// for more information about how to use them.
    init<Local: Entity, Foreign: Entity>(
        local: Local.Type,
        foreign: Foreign.Type,
        localKey: String = Foreign.idKey,
        foreignKey: String = Foreign.foreignIdKey
    ) {
        self.local = local
        self.foreign = foreign
        self.localKey = localKey
        self.foreignKey = foreignKey
    }
}

extension QueryRepresentable {
    /// Create and add a Join to this Query.
    ///
    /// See Join for more information.
    @discardableResult
    public func join<Foreign: Entity>(
        _ foreign: Foreign.Type,
        localKey: String = Foreign.idKey,
        foreignKey: String = Foreign.foreignIdKey
    ) throws -> Query<Self.T> {
        let query = try makeQuery()

        let join = Join(
            local: T.self,
            foreign: foreign,
            localKey: localKey,
            foreignKey: foreignKey
        )

        query.joins.append(join)

        return query
    }
}

/// Limits the count of results
/// returned by the `Query`

/// Groups results by an entity's
/// field.
public struct GroupBy {
    
    /// The entity to group by.
    public let entity: Entity.Type
    
    /// The field to group by.
    public let field: String
    
    public init(_ entity: Entity.Type, _ field: String) {
        self.entity = entity
        self.field = field
    }
}

extension QueryRepresentable {
    /// Groups results by a given entity's
    /// field.
    public func groupBy(_ field: String) throws -> Query<E> {
        let query = try makeQuery()
        let group = GroupBy(E.self, field)
        query.groups.append(group)
        return query
    }
}

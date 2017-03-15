extension QueryRepresentable {
    @discardableResult
    public func and(_ closure: (Query<E>) throws -> ()) throws -> Query<E> {
        return try group(.and, closure)
    }

    @discardableResult
    public func or(_ closure: (Query<E>) throws -> ()) throws -> Query<E> {
        return try group(.or, closure)
    }

    @discardableResult
    public func group(_ relation: Filter.Relation, _ closure: (Query<E>) throws -> ()) throws -> Query<E> {
        let main = try makeQuery()

        let sub = Query<E>(main.database)
        try closure(sub)

        let group = Filter(E.self, .group(relation, sub.filters))
        main.filters.append(group)

        return main
    }
}

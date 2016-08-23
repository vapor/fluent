extension QueryRepresentable {
    public func and(_ closure: (Query<T>) throws -> ()) throws -> Query<T> {
        return try group(.and, closure)
    }

    public func or(_ closure: (Query<T>) throws -> ()) throws -> Query<T> {
        return try group(.or, closure)
    }

    public func group(_ relation: Filter.Relation, _ closure: (Query<T>) throws -> ()) throws -> Query<T> {
        let main = try makeQuery()

        let sub = Query<T>(main.database)
        try closure(sub)

        let group = Filter(T.self, .group(relation, sub.filters))
        main.filters.append(group)

        return main
    }
}

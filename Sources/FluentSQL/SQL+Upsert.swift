extension Model where Database.Query: FluentSQLQuery {
    public func create(orUpdate: Bool, on conn: DatabaseConnectable) -> Future<Self> {
        return Self.query(on: conn).create(orUpdate: orUpdate, self)
    }
}

extension QueryBuilder where Database.Query: FluentSQLQuery, Result: Model, Result.Database == Database {
    public func create(orUpdate: Bool, _ model: Result) -> Future<Result> {
        guard orUpdate else {
            return create(model)
        }
        
        Database.queryActionApply(Database.queryActionCreate, to: &query)
        var copy: Result
        if Result.createdAtKey != nil || Result.updatedAtKey != nil {
            // set timestamps
            copy = model
            let now = Date()
            if copy.fluentUpdatedAt == nil {
                copy.fluentUpdatedAt = now
            }
            if copy.fluentCreatedAt == nil {
                copy.fluentCreatedAt = now
            }
        } else {
            copy = model
        }
        
        return connection.flatMap { conn in
            return Database.modelEvent(event: .willCreate, model: copy, on: conn).flatMap { model in
                return try model.willCreate(on: conn)
                }.flatMap { model -> Future<Result> in
                    var copy = model
                    try Database.queryDataApply(Database.queryEncode(copy, entity: Result.entity), to: &self.query)
                    do {
                        let row = SQLQueryEncoder(Database.Query.Upsert.Expression.self).encode(copy)
                        let values = row.map { row -> (Database.Query.Upsert.Identifier, Database.Query.Upsert.Expression) in
                            return (.identifier(row.key), row.value)
                        }
                        self.query.upsert = .upsert(values)
                    }
                    return self.run(Database.queryActionCreate) {
                        // to support reference types that may be ignoring return values
                        // set the id on the existing value before replacing it
                        copy.fluentID = $0.fluentID
                        // if a model is returned, use it since it may have default values
                        copy = $0
                    }.map { copy }
                }.flatMap { model in
                    return Database.modelEvent(event: .didCreate, model: model, on: conn)
                }.flatMap { model in
                    return try model.didCreate(on: conn)
            }
        }
    }

}

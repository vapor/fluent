public protocol QueryRepresentable {
    associatedtype E: Entity
    func makeQuery(_ executor: Executor) throws -> Query<E>
}

public protocol ExecutorRepresentable {
    func makeExecutor() throws -> Executor
}


extension QueryRepresentable where Self: ExecutorRepresentable {
    public func makeQuery() throws -> Query<E> {
        return try makeQuery(makeExecutor())
    }
}

// MARK: Fetch
extension QueryRepresentable where Self: ExecutorRepresentable {
    /// Returns all entities retrieved by the query.
    public func all() throws -> [E] {
        let query = try makeQuery()
        query.action = .fetch

        // if this is a soft deletable entity,
        // and soft deleted rows should not be included,
        // then filter them out
        if
            let S = E.self as? SoftDeletable.Type,
            !query.includeSoftDeleted
        {
            // require that all entities have deletedAt = null
            // or to some date in the future (not deleted yet)
            try query.or { subquery in
                try subquery.filter(S.deletedAtKey, Node.null)
                try subquery.filter(S.deletedAtKey, .greaterThan, Date())
            }
        }

        guard let array = try query.raw().array else {
            throw QueryError.invalidDriverResponse("Array required.")
        }

        var models: [E] = []

        for result in array {
            let row = Row(node: result)
            let model = try E(row: row)
            model.id = try row.get(E.idKey)
            model.exists = true

            // timestampable
            if
                let T = E.self as? Timestampable.Type,
                let t = model as? Timestampable
            {
                t.createdAt = try row.get(T.createdAtKey)
                t.updatedAt = try row.get(T.updatedAtKey)
            }

            // soft deletable
            if
                let S = E.self as? SoftDeletable.Type,
                let s = model as? SoftDeletable
            {
                s.deletedAt = try row.get(S.deletedAtKey)
            }

            models.append(model)
        }

        return models
    }

    /// Returns the first entity retrieved by the query.
    public func first() throws -> E? {
        let query = try makeQuery()
        query.action = .fetch
        try query.limit(1)

        let model = try query.all().first

        return model
    }

    /// Returns the first entity with the given `id`.
    public func find(_ id: NodeRepresentable) throws -> E? {
        return try makeQuery()
            .filter(E.idKey, id)
            .first()
    }

    /// Returns the number of results for the query.
    public func count() throws -> Int {
        let query = try makeQuery()
        query.action = .count

        // soft deletable
        if let S = E.self as? SoftDeletable.Type {
            try query.or { subquery in
                try subquery.filter(S.deletedAtKey, Node.null)
                try subquery.filter(S.deletedAtKey, .greaterThan, Date())
            }
        }

        let raw = try query.raw()

        let count: Int

        if let c = raw.int {
            count = c
        } else if let c = raw[0, "_fluent_count"]?.int {
            count = c
        } else {
            throw QueryError.notSupported("Count not supported.")
        }

        return count
    }
}

// MARK: Create
extension QueryRepresentable where Self: ExecutorRepresentable {
    /// Attempts the create action for the supplied
    /// serialized data.
    /// Returns the new entity's identifier.
    public func create(_ row: Row?) throws -> Identifier {
        let query = try makeQuery()

        query.action = .create
        try row.makeNode(in: query.context).rawOrObject?.forEach { (key, value) in
            query.data[key] = value
        }

        let raw = try query.raw()
        return Identifier(raw)
    }

    /// Attempts to save a supplied entity
    /// and updates its identifier if successful.
    public func save(_ model: E) throws {
        let query = try makeQuery()

        if let _ = model.id, model.exists {
            try model.willUpdate()
            var row = try model.makeRow()
            try row.set(E.idKey, model.id)

            // timestampable
            if
                let T = E.self as? Timestampable.Type,
                let t = model as? Timestampable
            {
                let now = Date()
                try row.set(T.updatedAtKey, now)
                t.updatedAt = now
            }

            // soft deletable
            if
                let S = E.self as? SoftDeletable.Type,
                let s = model as? SoftDeletable
            {
                if let deletedAt = s.deletedAt {
                    try row.set(S.deletedAtKey, deletedAt)
                } else {
                    try row.set(S.deletedAtKey, Node.null)
                }
            }

            try modify(row)
            model.didUpdate()
        } else {
            if model.id == nil, case .uuid = E.idType {
                // automatically generates uuids
                // for models without them
                model.id = Identifier(UUID.random())
            }
            try model.willCreate()
            var row = try model.makeRow()
            try row.set(E.idKey, model.id)

            // timestampable
            if
                let T = E.self as? Timestampable.Type,
                let t = model as? Timestampable
            {
                let now = Date()
                try row.set(T.createdAtKey, now)
                try row.set(T.updatedAtKey, now)
                t.createdAt = now
                t.updatedAt = now
            }

            let id = try query.create(row)
            if id != nil, id != .null, id != 0 {
                model.id = id
            }

            model.didCreate()
        }
        model.exists = true
    }
}

// MARK: Delete
extension QueryRepresentable where Self: ExecutorRepresentable {
    /// Attempts to delete all entities
    /// in the model's collection.
    public func delete() throws {
        let query = try makeQuery()
        query.action = .delete
        try query.raw()
    }

    /// Attempts to delete the supplied entity
    /// if its identifier is set.
    public func delete(_ model: E) throws {
        let id = try model.assertExists()
        let query = try makeQuery()

        // if the model is soft deletable and
        // does not have the force delete flag set,
        // then soft delete it.
        if
            let s = model as? SoftDeletable,
            !s.shouldForceDelete
        {
            // soft delete the model
            try s.softDelete()
            // note: model still 'exists'
        } else {
            // permenantly delete the model
            query.action = .delete
            try query.filter(E.idKey, id)
            try model.willDelete()
            try query.raw()
            model.didDelete()
            model.exists = false
        }
    }
}

// MARK: Update
extension QueryRepresentable where Self: ExecutorRepresentable {
    /// Attempts to modify model's collection with
    /// the supplied serialized data.
    public func modify(_ row: Row?) throws {
        let query = try makeQuery()

        query.action = .modify
        try row.makeNode(in: query.context).rawOrObject?.forEach { (key, value) in
            query.data[key] = value
        }

        let idKey = E.idKey
        if let id = row?[idKey] {
            _ = try filter(idKey, id)
        }
        
        try query.raw()
    }
}

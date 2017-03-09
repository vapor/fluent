public protocol QueryRepresentable {
    associatedtype T: Entity
    func makeQuery() throws -> Query<T>
}

// MARK: Fetch
extension QueryRepresentable {
    /// Returns the first entity retrieved by the query.
    public func first() throws -> T? {
        let query = try makeQuery()
        query.action = .fetch
        query.limit = Limit(count: 1)

        let model = try query.run().first
        model?.exists = true

        return model
    }

    /// Returns all entities retrieved by the query.
    public func all() throws -> [T] {
        let query = try makeQuery()

        query.action = .fetch

        let models = try query.run()
        models.forEach { model in
            let model = model
            model.exists = true
        }

        return models
    }

    /// Returns the number of results for the query.
    public func count() throws -> Int {
        let query = try makeQuery()
        query.action = .count

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
extension QueryRepresentable {
    /// Attempts the create action for the supplied
    /// serialized data.
    /// Returns the new entity's identifier.
    public func create(_ row: Row?) throws -> Identifier {
        let query = try makeQuery()

        query.action = .create
        query.data = try row.makeNode(in: query.context)

        let raw = try query.raw()
        return Identifier(raw)
    }

    /// Attempts to save a supplied entity
    /// and updates its identifier if successful.
    public func save(_ model: T) throws {
        let query = try makeQuery()

        if let _ = model.id, model.exists {
            try model.willUpdate()
            var row = try model.makeRow()
            try row.set(T.idKey, model.id)
            try modify(row)
            model.didUpdate()
        } else {
            if model.id == nil, case .uuid = T.idType {
                // automatically generates uuids
                // for models without them
                model.id = Identifier(UUID.random())
            }
            try model.willCreate()
            var row = try model.makeRow()
            try row.set(T.idKey, model.id)
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
extension QueryRepresentable {
    /// Attempts to delete all entities
    /// in the model's collection.
    public func delete() throws {
        let query = try makeQuery()

        guard query.joins.count == 0 else {
            throw QueryError.notSupported("Cannot perform delete on queries that contain joins. Delete the entities directly instead.")
        }

        query.action = .delete
        try query.raw()
    }

    /// Attempts to delete the supplied entity
    /// if its identifier is set.
    public func delete(_ model: T) throws {
        guard let id = model.id else {
            return
        }
        let query = try makeQuery()

        query.action = .delete

        let filter = Filter(
            T.self,
            .compare(
                T.idKey,
                .equals,
                id.makeNode(in: query.context)
            )
        )

        query.filters.append(filter)

        try model.willDelete()
        try query.raw()
        model.didDelete()

        let model = model
        model.exists = false
    }
}

// MARK: Update
extension QueryRepresentable {
    /// Attempts to modify model's collection with
    /// the supplied serialized data.
    public func modify(_ row: Row?) throws {
        let query = try makeQuery()

        query.action = .modify
        query.data = try row.makeNode(in: query.context)

        let idKey = T.idKey
        if let id = row?[idKey] {
            _ = try filter(idKey, id)
        }
        try query.run()
    }
}

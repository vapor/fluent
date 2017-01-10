/**
    Represents an abstract database query.
*/
public class Query<T: Entity>: QueryRepresentable {

    //MARK: Properties

    /**
        The type of action to perform
        on the data. Defaults to `.fetch`
    */
    public var action: Action

    /**
        An array of filters to apply
        during the query's action.
    */
    public var filters: [Filter]

    /**
        Optional data to be used during
        `.create` or `.updated` actions.
    */
    public var data: Node?

    /**
        Optionally limit the amount of
        entities affected by the action.
    */
    public var limit: Limit?

    /**
        An array of sorts that will
        be applied to the results.
    */
    public var sorts: [Sort]

    /**
        The collection or table name upon
        which the action should be performed.
    */
    public var entity: String {
        return T.entity
    }

    /**
        An array of unions, or other entities
        that will be queried during this query's
        execution.
    */
    public var unions: [Union]

    //MARK: Internal

    /**
        The database to which the query
        should be sent.
    */
    var database: Database

    /**
        Creates a new `Query` with the
        `Model`'s database.
    */
    public init(_ database: Database) {
        filters = []
        action = .fetch
        self.database = database
        unions = []
        sorts = []
    }

    var idKey: String {
        return database.driver.idKey
    }


    /**
        Runs the query given its properties
        and current state.

        Returns the Node from the driver.
    */
    @discardableResult
    public func raw() throws -> Node {
        return try database.driver.query(self)
    }

    /**
        Runs the query using Raw then converts
        the results to an array of models.
    */
    @discardableResult
    public func run() throws -> [T] {
        var models: [T] = []

        if case .array(let array) = try raw() {
            for result in array {
                do {
                    var model = try T(node: result)
                    if case .object(let dict) = result {
                        model.id = dict[database.driver.idKey]
                    }
                    models.append(model)
                } catch {
                    print("Could not initialize \(T.self), skipping: \(error)")
                }
            }
        } else {
            print("Unsupported Node type, only array is supported.")
        }

        return models
    }

    /**
        Conformance to `QueryRepresentable`
    */
    public func makeQuery() -> Query<T> {
        return self
    }
}

extension QueryRepresentable {
    /**
        Returns the first entity retreived
        by the query.
    */
    public func first() throws -> T? {
        let query = try makeQuery()
        query.limit = Limit(count: 1)

        var model = try query.run().first
        model?.exists = true

        return model
    }

    /**
        Returns all entities retreived
        by the query.
    */
    public func all() throws -> [T] {
        let query = try makeQuery()

        let models = try query.run()
        models.forEach { model in
            var model = model
            model.exists = true
        }

        return models
    }
    
    /**
     Returns the number of results for the query.
     */
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

    //MARK: Create

    /**
        Attempts the create action for the supplied
        serialized data.

        Returns the new entity's identifier.
    */
    public func create(_ serialized: Node?) throws -> Node {
        let query = try makeQuery()

        query.action = .create
        query.data = serialized

        return try query.raw()
    }

    /**
        Attempts to save a supplied entity
        and updates its identifier if successful.
    */
    public func save(_ model: inout T) throws {
        let query = try makeQuery()
        
        if let _ = model.id, model.exists {
            model.willUpdate()
            try modify(model.makeNode())
            model.didUpdate()
        } else {
            model.willCreate()
            model.id = try query.create(model.makeNode())
            model.didCreate()
        }
        model.exists = true
    }

    //MARK: Delete

    /**
        Attempts to delete all entities
        in the model's collection.
    */
    public func delete() throws {
        let query = try makeQuery()
        
        guard query.unions.count == 0 else {
            throw QueryError.notSupported("Cannot perform delete on queries that contain unions. Delete the entities directly instead.")
        }
        
        query.action = .delete
        try query.run()
    }

    /**
        Attempts to delete the supplied entity
        if its identifier is set.
    */
    public func delete(_ model: T) throws {
        guard let id = model.id else {
            return
        }
        let query = try makeQuery()

        query.action = .delete

        let filter = Filter(
            T.self,
            .compare(
                query.database.driver.idKey,
                .equals,
                id
            )
        )

        query.filters.append(filter)

        model.willDelete()
        try query.run()
        model.didDelete()

        var model = model
        model.exists = false
    }

    //MARK: Update

    /**
        Attempts to modify model's collection with
        the supplied serialized data.
    */
    public func modify(_ serialized: Node?) throws {
        let query = try makeQuery()

        query.action = .modify
        query.data = serialized

        let idKey = query.database.driver.idKey
        if let id = serialized?[idKey] {
            _ = try filter(idKey, id)
        }
        try query.run()
    }
}

public enum QueryError: Error {
    case notSupported(String)
}

public protocol QueryRepresentable {
    associatedtype T: Entity
    func makeQuery() throws -> Query<T>
}

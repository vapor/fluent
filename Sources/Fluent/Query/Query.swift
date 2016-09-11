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
        return try query.run().first
    }

    /**
        Returns all entities retreived
        by the query.
    */
    public func all() throws -> [T] {
        let query = try makeQuery()
        return try query.run()
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
        let data = try model.makeNode()

        if let id = model.id {
            let _ = try filter(
                query.database.driver.idKey,
                .equals,
                id
            )
            try modify(data)
        } else {
            model.id = try query.create(data)
        }
    }

    //MARK: Delete

    /**
        Attempts to delete all entities
        in the model's collection.
    */
    public func delete() throws {
        let query = try makeQuery()
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

        try query.run()
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

        // FIXME: There should be a flag to know if this existed to prevent overwriting existing id
        let idKey = query.database.driver.idKey
        serialized?[idKey].flatMap { id in
            let entity = T.self
            let idFilter = Filter(entity, .compare(idKey, .equals, id))
            query.filters.append(idFilter)
        }

        try query.run()
    }
}

public protocol QueryRepresentable {
    associatedtype T: Entity
    func makeQuery() throws -> Query<T>
}

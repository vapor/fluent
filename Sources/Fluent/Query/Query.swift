/**
    Represents an abstract database query.
*/
public class Query<T: Model> {

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
    public var data: [String: Value]?

    /**
        Optionally limit the amount of
        entities affected by the action.
    */
    public var limit: Limit?

    /**
        The collection or table name upon
        which the action should be performed.
    */
    public var entity: String {
        return T.entity
    }

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
    public init() {
        filters = []
        action = .fetch
        database = T.database
    }

    /**
        Runs the query given its properties
        and current state. 
     
        Returns an array of entities.
    */
    // @discardableResult
    func run() throws -> [T] {
        var models: [T] = []

        let results = try database.driver.query(self)

        for result in results {
            var model = T(serialized: result)
            model.id = result[database.driver.idKey]
            models.append(model)
        }

        return models
    }

    //MARK: Fetch

    /**
        Returns the first entity retreived
        by the query.
    */
    public func first() throws -> T? {
        limit = Limit(count: 1)
        return try run().first
    }

    /**
        Returns all entities retreived
        by the query.
    */
    public func all() throws -> [T] {
        return try run()
    }

    //MARK: Create

    /**
        Attempts the create action for the supplied
        serialized data. 
     
        Returns an entity if one was created.
    */
    public func create(_ serialized: [String: Value?]) throws -> T? {
        action = .create
        data = nilToNull(serialized)
        
        return try run().first
    }

    /**
        Attempts to save a supplied entity
        and updates its identifier if successful.
    */
    public func save(_ model: inout T) throws {
        let data = model.serialize()

        if let id = model.id {
            let _ = filter(database.driver.idKey, .equals, id) // discardableResult
            try modify(data)
        } else {
            let new = try create(data)
            model.id = new?.id
        }
    }

    //MARK: Delete

    /**
        Attempts to delete all entities
        in the model's collection.
    */
    public func delete() throws {
        action = .delete
        let _ = try run() // discardableResult
    }

    /**
        Attempts to delete the supplied entity
        if its identifier is set.
    */
    public func delete(_ model: T) throws {
        guard let id = model.id else {
            return
        }
        action = .delete
        
        let filter = Filter.compare(database.driver.idKey, .equals, id)
        filters.append(filter)

       let _ = try run() // discardableResult
    }

    //MARK: Update

    /**
        Attempts to modify model's collection with
        the supplied serialized data.
    */
    public func modify(_ serialized: [String: Value?]) throws {
        action = .modify
        data = nilToNull(serialized)
        let _ = try run() // discardableResult
    }


    //MARK: Filter

    /**
        Adds a `.compare` filter to the query's
        filters.
     
        Used for filtering results based on how
        a result's value compares to the supplied value.
    */
    @discardableResult
    public func filter(_ field: String, _ comparison: Filter.Comparison, _ value: Value) -> Self {
        let filter = Filter.compare(field, comparison, value)
        filters.append(filter)
        return self
    }

    /**
        Adds a `.subset` filter to the query's
        filters. 
     
        Used for filtering results based on whether
        a result's value is or is not in a set.
    */
    @discardableResult
    public func filter(_ field: String, _ scope: Filter.Scope, _ set: [Value]) -> Self {
        let filter = Filter.subset(field, scope, set)
        filters.append(filter)
        return self
    }


    /**
        Shortcut for creating a `.equals` filter.
    */
    @discardableResult
    public func filter(_ field: String, _ value: Value) -> Self {
        return filter(field, .equals, value)
    }

    private func nilToNull(_ serialized: [String: Value?]) -> [String: Value] {
        var converted: [String: Value] = [:]

        for (key, value) in serialized {
            converted[key] = value ?? StructuredData.null
        }

        return converted
    }

}

extension Query: CustomStringConvertible {
    public var description: String {
        return "\(action) \(entity), \(filters.count) filters"
    }
}

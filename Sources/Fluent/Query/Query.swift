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
    
    public var fields: [String]
    
    public var relationFields: [(table: String, fields: [String])]

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
        fields = []
        relationFields = []
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
    public func run() throws -> [T] {
        var models: [T] = []

        if case .array(let array) = try raw() {
            for result in array {
                do {
                    var model = try T(node: result)
                    if case .object(let dict) = result {
                        model.id = dict[database.driver.idKey]
                    }
                    model.exists = true
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
    
    public func run<Relation: Entity>(including relation: Relation.Type) throws -> [(T, Relation)] {
        var models: [(T, Relation)] = []

        if case .array(let array) = try raw() {
            for result in array {
                guard let object = result.nodeObject else {
                    print("Unsupported row Node type, only object is supported.")
                    continue
                }
                
                var model: T
                var relationModel: Relation
                
                do {
                    model = try T(node: result)
                } catch {
                    print("Could not initialize \(T.self), skipping: \(error)")
                    continue
                }
                
                // Filter out only the relation fields
                let relationFieldPrefix = "\(Relation.entity)_"
                let relationFieldPrefixLength = relationFieldPrefix.distance(from: relationFieldPrefix.startIndex, to: relationFieldPrefix.endIndex)
                var relationFields: [String:Node] = [:]
                for (key, value) in object {
                    guard key.hasPrefix(relationFieldPrefix) else {
                        continue
                    }
                    let relationKey = key.replacingCharacters(in: key.startIndex..<key.index(key.startIndex, offsetBy: relationFieldPrefixLength), with: "")
                    relationFields[relationKey] = value
                }
                let relationResult = Node.object(relationFields)
                
                do {
                    relationModel = try Relation(node: relationResult)
                } catch {
                    print("Could not initialize \(Relation.self), skipping: \(error)")
                    continue
                }
                
                let idKey = database.driver.idKey
                model.id = result[idKey]
                relationModel.id = relationResult[idKey]
                
                model.exists = true
                relationModel.exists = true
                
                models.append((model, relationModel))
                
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
        
        query.fields = T.fields(for: query.database)

        return try query.run().first
    }
    
    public func first<Relation: Entity>(including relation: Relation.Type) throws -> (T, Relation)? {
        let query = try makeQuery()
        query.limit = Limit(count: 1)
        
        query.fields = T.fields(for: query.database)
        let relationFields = Relation.fields(for: query.database)
        query.relationFields = [(table: Relation.entity, fields: relationFields)]
        
        return try query.run(including: relation).first
    }

    /**
        Returns all entities retreived
        by the query.
    */
    public func all() throws -> [T] {
        let query = try makeQuery()
        query.fields = T.fields(for: query.database)
        return try query.run()
    }
    
    public func all<Relation: Entity>(including relation: Relation.Type) throws -> [(T, Relation)] {
        let query = try makeQuery()
        
        query.fields = T.fields(for: query.database)
        let relationFields = Relation.fields(for: query.database)
        query.relationFields = [(table: Relation.entity, fields: relationFields)]
        
        return try query.run(including: relation)
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

        if let _ = model.id, model.exists {
            model.willUpdate()
            try modify(data)
            model.didUpdate()
        } else {
            model.willCreate()
            model.id = try query.create(data)
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
        query.action = .delete
        try query.raw()
    }

    /**
        Attempts to delete the supplied entity
        if its identifier is set.
    */
    public func delete(_ model: inout T) throws {
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
        try query.raw()
        model.didDelete()

        model.id = nil
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
        try query.raw()
    }
}

public protocol QueryRepresentable {
    associatedtype T: Entity
    func makeQuery() throws -> Query<T>
}

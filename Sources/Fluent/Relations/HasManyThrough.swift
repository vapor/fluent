extension Model {

/**
     A helper method to retrieve child objects through an existing relationship
     
     `Parent` and `Child` are Generic representations of `Model`

     # Usage #
     Assuming the following data model:
     `Catalogs` have many `Departments` have many `Categories` have many `Products`
     a `Catalog` can query all of the `Products` through the chain of `Catalog`'s child relationships
     ```
     final class Catalog: Model {
        ...
        // A standard `Children` relationship
        var departments: Children<Catalog, Department> {
            return children(\.catalogID)
        }
     
        // This utilizies a similar helper method: `queryChildren(of children: through: on conn: filter:)`
        func categories(_ conn: DatabaseConnectable) -> Future<[Category]> {
            return queryChildren(of: self.departments, through: \.categories, on: conn)
        }
     
        // This method is the result of chaining futures to get all `Products` belonging to this `Catalog`
        func products(_ conn: DatabaseConnectable) -> Future<[Product]> {
            return queryChildren(of: categories(conn), through: \.products, on: conn)
        }
     
        // Example that uses a custom filter
        func highInventoryProducts(_ conn: DatabaseConnectable) -> Future<[Product]> {
            return queryChildren(of: categories(conn), through: \.products, on: conn) { query in
                return query.filter(\Product.inventory >= 100).all()
            }
        }
     }
     ```

     - Parameter parents: The future result of a query on an existing `Children` (one to many relationship)
     - Parameter through: The keypath on the `Parent` to the desired `Child` relationship
     - Parameter conn: The `DatabaseConnectable` that will be used to make queries
     - Parameter filter: A closure that will return a filtered result on the query. By default this returns all results from the query
     
     - Returns: A future array of `Child` objects
     
     - SeeAlso: `func queryChildren(of children: through: on conn: filter:)`
*/
    public func queryChildren<Parent, Child> (
        of parents: Future<[Parent]>,
        through: KeyPath<Parent, Children<Parent, Child>>,
        on conn: DatabaseConnectable,
        filter: @escaping (QueryBuilder<Child.Database, Child>) -> Future<[Child]> = { query in return query.all() }
        ) -> Future<[Child]>
        where Parent: Model, Child: Model, Parent.Database == Child.Database {
        
        let promise = conn.eventLoop.newPromise([Child].self)
        _ = parents.map(to:[QueryBuilder<Child.Database, Child>].self) { parents in
            return parents.map { parent in
                try? parent[keyPath: through].query(on: conn)
            }.filter { query in
                query != nil
            } as! [QueryBuilder<Child.Database, Child>]
        }.map(to:[Future<[Child]>].self) { queries in
            return queries.map { query in
                filter(query)
            }
        }.map(to: Future<[Child]>.self) { results in
            let future: Future<[Child]> = conn.eventLoop.submit{ [] }
            return future.fold(results) { (children: [Child], moreChildren: [Child]) -> Future<[Child]> in
                return conn.eventLoop.newSucceededFuture(result: children + moreChildren)
            }
        }.map { future in
            future.map { result in
                promise.succeed(result: result)
            }
        }.catch { error in
            promise.fail(error: error)
        }
        
        return promise.futureResult
    }

/**
     A helper method to retrieve child objects through that firsts queries a `Children` relationship
     
     `GrandParent`, `Parent` and `Child` are Generic representations of `Model`
     
     - Parameter children: A `Children` relationship
     - Parameter through: The keypath on the `Parent` to the desired `Child` relationship
     - Parameter conn: The `DatabaseConnectable` that will be used to make queries
     - Parameter filter: A closure that will return a filtered result on the query. By default this returns all results from the query
     
     - Returns: A future array of `Child` objects
     
     - SeeAlso: `func queryChildren(of parents: through: on conn: filter:)`

*/
    public func queryChildren<GrandParent, Parent, Child> (
        of children: Children<GrandParent, Parent>,
        through: KeyPath<Parent, Children<Parent, Child>>,
        on conn: DatabaseConnectable,
        filter: @escaping (QueryBuilder<Child.Database, Child>) -> Future<[Child]> = { query in return query.all() }
        ) -> Future<[Child]>
        where GrandParent: Model,
              Parent: Model,
              Child: Model,
              GrandParent.Database == Parent.Database,
              Parent.Database == Child.Database {
            guard let result = try? children.query(on: conn).all() else {
                return conn.eventLoop.newSucceededFuture(result: [])
            }
            return queryChildren(of: result, through: through, on: conn, filter: filter)
    }
    
}

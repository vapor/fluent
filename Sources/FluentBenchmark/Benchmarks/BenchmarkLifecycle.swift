// Lifecycle tests courtesy of the wonderful @mcdappdev

import Fluent

extension Benchmarker where Database: QuerySupporting {
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        //create a lifecycle user
        let user = LifecycleUser<Database>(name: "user")
        _ = try test(user.save(on: conn))

        if !LifecycleUserStateTracking.willCreateCalled || !LifecycleUserStateTracking.didCreateCalled {
            self.fail("willCreate and didCreate should be called")
        }

        //update the user
        user.name =  "new name"
        _ = try test(user.save(on: conn))

        if !LifecycleUserStateTracking.willUpdateCalled || !LifecycleUserStateTracking.didUpdateCalled {
            self.fail("willUpdate and didUpdate should be called")
        }

        //delete the user
        _ = try test(user.delete(on: conn))

        if !LifecycleUserStateTracking.willDeleteCalled || !LifecycleUserStateTracking.didDeleteCalled {
            self.fail("willDelete and didDelete should be called")
        }
    }

    public func benchmarkLifecycle() throws {
        let conn = try test(pool.requestConnection())
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: SchemaSupporting & MigrationSupporting {
    /// Benchmarks misc bugs, preparing the schema first.
    public func benchmarkLifecycle_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(LifecycleUser<Database>.prepare(on: conn))
        defer { try? test(LifecycleUser<Database>.revert(on: conn)) }
        try self._benchmark(on: conn)
        pool.releaseConnection(conn)
    }
}

final class LifecycleUser<D>:  Model where D: QuerySupporting {
    /// See Model.Database
    typealias Database = D

    /// See Model.ID
    typealias ID = Int

    /// See Model.idKey
    static var idKey: IDKey { return \.id }

    static var entity: String { return "lifecycle_users" }

    /// Foo's identifier
    var id: Int?

    /// Name string
    var name: String?

    /// Creates a new `BasicUser`
    init(id: Int? = nil, name: String?) {
        self.id = id
        self.name = name
    }

    func willCreate(on connection: D.Connection) throws -> EventLoopFuture<LifecycleUser<D>> {
        LifecycleUserStateTracking.willCreateCalled = true
        return Future.map(on: connection) { self }
    }

    func didCreate(on connection: D.Connection) throws -> EventLoopFuture<LifecycleUser<D>> {
        LifecycleUserStateTracking.didCreateCalled = true
        return Future.map(on: connection) { self }
    }

    func willUpdate(on connection: D.Connection) throws -> EventLoopFuture<LifecycleUser<D>> {
        LifecycleUserStateTracking.willUpdateCalled = true
        return Future.map(on: connection) { self }
    }

    func didUpdate(on connection: D.Connection) throws -> EventLoopFuture<LifecycleUser<D>> {
        LifecycleUserStateTracking.didUpdateCalled = true
        return Future.map(on: connection) { self }
    }

    func willDelete(on connection: D.Connection) throws -> EventLoopFuture<LifecycleUser<D>> {
        LifecycleUserStateTracking.willDeleteCalled = true
        return Future.map(on: connection) { self }
    }

    func didDelete(on connection: D.Connection) throws -> EventLoopFuture<LifecycleUser<D>> {
        LifecycleUserStateTracking.didDeleteCalled = true
        return Future.map(on: connection) { self }
    }
}

class LifecycleUserStateTracking {
    static var willCreateCalled = false
    static var didCreateCalled = false
    static var willUpdateCalled = false
    static var didUpdateCalled = false
    static var willDeleteCalled = false
    static var didDeleteCalled = false
}

extension LifecycleUser: Migration, AnyMigration where D: SchemaSupporting & MigrationSupporting { }

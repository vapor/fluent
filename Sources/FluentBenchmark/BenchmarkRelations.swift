import Async
import Dispatch
import Fluent
import Foundation

extension Benchmarker where Database: JoinSupporting & ReferenceSupporting & QuerySupporting {
    /// The actual benchmark.
    fileprivate func _benchmark(on conn: Database.Connection) throws {
        // create
        let tanner = User<Database>(name: "Tanner", age: 23)
        _ = try test(tanner.save(on: conn))

        let ziz = try Pet<Database>(name: "Ziz", ownerID: tanner.requireID())
        _ = try test(ziz.save(on: conn))

        let foo = Pet<Database>(name: "Foo", ownerID: UUID())
        do {
            _ = try foo.save(on: conn).await(on: eventLoop)
            fail("save should have failed")
        } catch {
            // pass
        }

        var count = try test(tanner.pets.query(on: conn).count())
        if count != 1 {
            self.fail("count should have been 1")
        }

        let owner = try test(ziz.owner.get(on: conn))
        if owner.name != "Tanner" {
            self.fail("pet owner's name wrong")
        }

        let plasticBag = Toy<Database>(name: "Plastic Bag")
        _ = try test(plasticBag.save(on: conn))

        let oldBologna = Toy<Database>(name: "Old Bologna")
        _ = try test(oldBologna.save(on: conn))

        _ = try test(ziz.toys.attach(plasticBag, on: conn))
        _ = try test(oldBologna.pets.attach(ziz, on: conn))

        count = try test(ziz.toys.query(on: conn).count())
        if count != 2 {
            self.fail("count should have been 2")
        }

        count = try test(oldBologna.pets.query(on: conn).count())
        if count != 1 {
            self.fail("count should have been 1")
        }

        count = try test(plasticBag.pets.query(on: conn).count())
        if count != 1 {
            self.fail("count should have been 1")
        }

        if try !test(ziz.toys.isAttached(plasticBag, on: conn)) {
            self.fail("should be attached")
        }
        try test(ziz.toys.detach(plasticBag, on: conn))

        if try test(ziz.toys.isAttached(plasticBag, on: conn)) {
            self.fail("should not be attached")
        }
    }

    /// Benchmark fluent relations.
    public func benchmarkRelations() throws {
        let conn = try test(pool.requestConnection())
        try test(Database.enableReferences(on: conn))
        try self._benchmark(on: conn)
        self.pool.releaseConnection(conn)
    }
}

extension Benchmarker where Database: SchemaSupporting & JoinSupporting & ReferenceSupporting & QuerySupporting {
    /// Benchmark fluent relations.
    /// The schema will be prepared first.
    public func benchmarkRelations_withSchema() throws {
        let conn = try test(pool.requestConnection())
        try test(Database.enableReferences(on: conn))

        try test(UserMigration<Database>.prepare(on: conn))
        try test(PetMigration<Database>.prepare(on: conn))
        try test(ToyMigration<Database>.prepare(on: conn))
        try test(PetToyMigration<Database>.prepare(on: conn))

        try self._benchmark(on: conn)

        try test(PetToyMigration<Database>.revert(on: conn))
        try test(ToyMigration<Database>.revert(on: conn))
        try test(PetMigration<Database>.revert(on: conn))
        try test(UserMigration<Database>.revert(on: conn))

        self.pool.releaseConnection(conn)
    }
}


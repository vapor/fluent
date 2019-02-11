import FluentKit
import Foundation
import XCTest

public final class FluentBenchmarker {
    public let database: FluentDatabase
    
    public init(database: FluentDatabase) {
        self.database = database
    }
    
    public func testAll() throws {
        try self.testCreate()
        try self.testRead()
        try self.testUpdate()
        try self.testDelete()
        try self.testEagerLoadChildren()
        try self.testEagerLoadParent()
    }
    
    public func testCreate() throws {
        try self.runTest(#function, [
            Galaxy.autoMigration()
        ]) {
            let galaxy = Galaxy.new()
            galaxy.name.set(to: "Messier 82")
            try galaxy.save(on: self.database).wait()
            guard try galaxy.id.get() == 1 else {
                throw Failure("unexpected galaxy id: \(galaxy)")
            }
            
            guard let fetched = try self.database.query(Galaxy.self).filter(\.name == "Messier 82").first().wait() else {
                throw Failure("unexpected empty result set")
            }
            
            if try fetched.name.get() != galaxy.name.get() {
                throw Failure("unexpected name: \(galaxy) \(fetched)")
            }
            if try fetched.id.get() != galaxy.id.get() {
                throw Failure("unexpected id: \(galaxy) \(fetched)")
            }
        }
    }
    
    public func testRead() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            GalaxySeed()
        ]) {
            guard let milkyWay = try self.database.query(Galaxy.self)
                .filter(\.name == "Milky Way")
                .first().wait()
                else {
                    throw Failure("unpexected missing galaxy")
            }
            guard try milkyWay.name.get() == "Milky Way" else {
                throw Failure("unexpected name")
            }
        }
    }
    
    public func testUpdate() throws {
        try runTest(#function, [
            Galaxy.autoMigration()
        ]) {
            let galaxy = Galaxy.new()
            galaxy.name.set(to: "Milkey Way")
            try galaxy.save(on: self.database).wait()
            galaxy.name.set(to: "Milky Way")
            try galaxy.save(on: self.database).wait()
            
            // verify
            let galaxies = try self.database.query(Galaxy.self).filter(\.name == "Milky Way").all().wait()
            guard galaxies.count == 1 else {
                throw Failure("unexpected galaxy count: \(galaxies)")
            }
            guard try galaxies[0].name.get() == "Milky Way" else {
                throw Failure("unexpected galaxy name")
            }
        }
    }
    
    public func testDelete() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
        ]) {
            let galaxy = Galaxy.new()
            galaxy.name.set(to: "Milky Way")
            try galaxy.save(on: self.database).wait()
            try galaxy.delete(on: self.database).wait()
            
            // verify
            let galaxies = try self.database.query(Galaxy.self).all().wait()
            guard galaxies.count == 0 else {
                throw Failure("unexpected galaxy count: \(galaxies)")
            }
        }
    }
    
    public func testEagerLoadChildren() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            Planet.autoMigration(),
            GalaxySeed(),
            PlanetSeed()
        ]) {
            let galaxies = try self.database.query(Galaxy.self)
                .with(\.planets)
                .all().wait()

            for galaxy in galaxies {
                let planets = try galaxy.planets.get()
                switch try galaxy.name.get() {
                case "Milky Way":
                    guard try planets.contains(where: { try $0.name.get() == "Earth" }) else {
                        throw Failure("unexpected missing planet")
                    }
                    guard try !planets.contains(where: { try $0.name.get() == "PA-99-N2"}) else {
                        throw Failure("unexpected planet")
                    }
                default: break
                }
            }
        }
    }
    
    public func testEagerLoadParent() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            Planet.autoMigration(),
            GalaxySeed(),
            PlanetSeed()
        ]) {
            let planets = try self.database.query(Planet.self)
                .with(\.galaxy)
                .all().wait()
            
            for planet in planets {
                let galaxy = try planet.galaxy.get()
                switch try planet.name.get() {
                case "Earth":
                    guard try galaxy.name.get() == "Milky Way" else {
                        throw Failure("unexpected galaxy name: \(galaxy)")
                    }
                case "PA-99-N2":
                    guard try galaxy.name.get() == "Andromeda" else {
                        throw Failure("unexpected galaxy name: \(galaxy)")
                    }
                default: break
                }
            }
        }
    }
    
    public func testEagerLoadParentJoin() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            Planet.autoMigration(),
            GalaxySeed(),
            PlanetSeed()
        ]) {
            let planets = try self.database.query(Planet.self)
                .with(\.galaxy, method: .join)
                .all().wait()
            
            for planet in planets {
                let galaxy = try planet.galaxy.get()
                switch try planet.name.get() {
                case "Earth":
                    guard try galaxy.name.get() == "Milky Way" else {
                        throw Failure("unexpected galaxy name: \(galaxy)")
                    }
                case "PA-99-N2":
                    guard try galaxy.name.get() == "Andromeda" else {
                        throw Failure("unexpected galaxy name: \(galaxy)")
                    }
                default: break
                }
            }
        }
    }
    
    public func testEagerLoadSubqueryJSONEncode() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            Planet.autoMigration(),
            GalaxySeed(),
            PlanetSeed()
        ]) {
            let planets = try self.database.query(Planet.self)
                .with(\.galaxy, method: .subquery)
                .all().wait()
            
            let encoder = JSONEncoder()
            let json = try encoder.encode(planets)
            let string = String(data: json, encoding: .utf8)!
            
            let expected = """
            [{"id":1,"name":"Mercury","galaxy":{"id":2,"name":"Milky Way"}},{"id":2,"name":"Venus","galaxy":{"id":2,"name":"Milky Way"}},{"id":3,"name":"Earth","galaxy":{"id":2,"name":"Milky Way"}},{"id":4,"name":"Mars","galaxy":{"id":2,"name":"Milky Way"}},{"id":5,"name":"Jupiter","galaxy":{"id":2,"name":"Milky Way"}},{"id":6,"name":"Saturn","galaxy":{"id":2,"name":"Milky Way"}},{"id":7,"name":"Uranus","galaxy":{"id":2,"name":"Milky Way"}},{"id":8,"name":"Neptune","galaxy":{"id":2,"name":"Milky Way"}},{"id":9,"name":"PA-99-N2","galaxy":{"id":1,"name":"Andromeda"}}]
            """
            guard string == expected else {
                throw Failure("unexpected json format")
            }
        }
    }
    
    public func testEagerLoadJoinJSONEncode() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            Planet.autoMigration(),
            GalaxySeed(),
            PlanetSeed()
        ]) {
            let planets = try self.database.query(Planet.self)
                .with(\.galaxy, method: .join)
                .all().wait()
            
            let encoder = JSONEncoder()
            let json = try encoder.encode(planets)
            let string = String(data: json, encoding: .utf8)!
            
            let expected = """
            [{"id":1,"name":"Mercury","galaxy":{"id":2,"name":"Milky Way"}},{"id":2,"name":"Venus","galaxy":{"id":2,"name":"Milky Way"}},{"id":3,"name":"Earth","galaxy":{"id":2,"name":"Milky Way"}},{"id":4,"name":"Mars","galaxy":{"id":2,"name":"Milky Way"}},{"id":5,"name":"Jupiter","galaxy":{"id":2,"name":"Milky Way"}},{"id":6,"name":"Saturn","galaxy":{"id":2,"name":"Milky Way"}},{"id":7,"name":"Uranus","galaxy":{"id":2,"name":"Milky Way"}},{"id":8,"name":"Neptune","galaxy":{"id":2,"name":"Milky Way"}},{"id":9,"name":"PA-99-N2","galaxy":{"id":1,"name":"Andromeda"}}]
            """
            guard string == expected else {
                throw Failure("unexpected json format")
            }
        }
    }
    
    public func testMigrator() throws {
        try self.runTest(#function, []) {
            var migrations = FluentMigrations()
            migrations.add(Galaxy.autoMigration())
            migrations.add(Planet.autoMigration())
            
            var databases = FluentDatabases()
            databases.add(self.database, as: .init(string: "main"))
            
            let migrator = FluentMigrator(
                databases: databases,
                migrations: migrations,
                on: self.database.eventLoop
            )
            try migrator.prepare().wait()
            try migrator.revertAll().wait()
        }
    }
    
    public func testMigratorError() throws {
        try self.runTest(#function, []) {
            var migrations = FluentMigrations()
            migrations.add(Galaxy.autoMigration())
            migrations.add(ErrorMigration())
            migrations.add(Planet.autoMigration())
            
            var databases = FluentDatabases()
            databases.add(self.database, as: .init(string: "main"))
            
            let migrator = FluentMigrator(
                databases: databases,
                migrations: migrations,
                on: self.database.eventLoop
            )
            do {
                try migrator.prepare().wait()
                throw Failure("prepare did not fail")
            } catch {
                // success
                self.log("Migration failed: \(error)")
            }
            try migrator.revertAll().wait()
        }
    }
    
    public func testJoin() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            Planet.autoMigration(),
            GalaxySeed(),
            PlanetSeed()
        ]) {
            let planets = try self.database.query(Planet.self)
                .join(\.galaxy)
                .all().wait()
            print(planets)
        }
    }
    
    public func testBatchCreate() throws {
        try runTest(#function, [
            Galaxy.autoMigration()
        ]) {
            let galaxies = Array("abcdefghijklmnopqrstuvwxyz").map { letter -> Galaxy in
                let galaxy = Galaxy.new()
                galaxy.name.set(to: String(letter))
                return galaxy
            }
                
            try galaxies.create(on: self.database).wait()
            guard try galaxies[5].id.get() == 6 else {
                throw Failure("batch insert did not set id")
            }
        }
    }
    
    public func testBatchUpdate() throws {
        try runTest(#function, [
            Galaxy.autoMigration(),
            GalaxySeed()
        ]) {
            try self.database.query(Galaxy.self).set(\.name, to: "Foo")
                .update().wait()
            
            let galaxies = try self.database.query(Galaxy.self).all().wait()
            for galaxy in galaxies {
                
                guard try galaxy.name.get() == "Foo" else {
                    throw Failure("batch update did not set id")
                }
            }
        }
    }
    
//    public func testWorkUnit() throws {
//        try runTest(#function, [
//            Galaxy.autoMigration()
//        ]) {
//            let unit = self.database.workUnit()
//            
//            let galaxy = Galaxy.new()
//            galaxy.name.set(to: "Milky Way")
//            try galaxy.save(on: unit).wait()
//            try galaxy.save(on: unit).wait()
//            try galaxy.save(on: unit).wait()
//            
//            do {
//                let galaxies = try self.database.query(Galaxy.self).all().wait()
//                guard galaxies.count == 0 else {
//                    throw Failure("expected galaxy count to be 0 before commit")
//                }
//            }
//            
//            try unit.commit().wait()
//            
//            do {
//                let galaxies = try self.database.query(Galaxy.self).all().wait()
//                guard galaxies.count == 1 else {
//                    throw Failure("expected galaxy count to be 1 after commit")
//                }
//            }
//        }
//    }
    
    public func testNestedModel() throws {
        try runTest(#function, [
            User.autoMigration(),
            UserSeed()
        ]) {
            let users = try self.database.query(User.self)
                .filter(\.pet.type == .cat)
                .all().wait()
        
            guard let user = users.first, users.count == 1 else {
                throw Failure("unexpected user count")
            }
            guard try user.name.get() == "Tanner" else {
                throw Failure("unexpected user name")
            }
            guard try user.pet.name.get() == "Ziz" else {
                throw Failure("unexpected pet name")
            }
            guard try user.pet.type.get() == .cat else {
                throw Failure("unexpected pet type")
            }
            
            let encoder = JSONEncoder()
            let json = try encoder.encode(user)
            let string = String(data: json, encoding: .utf8)!
            let expected = """
            {"id":2,"name":"Tanner","pet":{"name":"Ziz","type":"cat"}}
            """
            guard string == expected else {
                throw Failure("unexpected output")
            }
        }
    }
    
    struct Failure: Error {
        let reason: String
        let line: UInt
        let file: StaticString
        
        init(_ reason: String, line: UInt = #line, file: StaticString = #file) {
            self.reason = reason
            self.line = line
            self.file = file
        }
    }
    
    private func runTest(_ name: String, _ migrations: [FluentMigration], _ test: () throws -> ()) throws {
        self.log("Running \(name)...")
        for migration in migrations {
            do {
                try migration.prepare(on: self.database).wait()
            } catch {
                self.log("Migration failed, attempting to revert existing...")
                try migration.revert(on: self.database).wait()
                try migration.prepare(on: self.database).wait()
            }
        }
        var e: Error?
        do {
            try test()
        } catch let failure as Failure {
            XCTFail(failure.reason, file: failure.file, line: failure.line)
        } catch {
            e = error
        }
        for migration in migrations {
            try migration.revert(on: self.database).wait()
        }
        if let error = e {
            throw error
        }
    }
    
    private func log(_ message: String) {
        print("[FluentBenchmark] \(message)")
    }
}

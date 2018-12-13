import Fluent
import Foundation

public final class FluentBenchmarker {
    public let database: FluentDatabase
    
    public init(database: FluentDatabase) {
        self.database = database
    }
    
    public func testAll() throws {
        try self.testBasics()
        try self.testEagerLoad()
        try self.testEagerLoad()
    }
    
    public func runTest(_ test: () -> (), migrations: [Migration]) {
        fatalError()
    }
    
    public func testBasics() throws {
        print("[BASIC]")
        let res = try self.database.query(Galaxy.self)
            .filter(\.name == "Milky Way")
            .all().wait()
        print(res)
    }
    
    public func testEagerLoad() throws {
        print("[EAGER LOAD]")
        
        // SELECT "galaxies"."id", "galaxies"."name" FROM "galaxies"
        let galaxies = try self.database.query(Galaxy.self)
            .with(\.planets)
            .all().wait()
        print(galaxies) // [Galaxy]

        // SELECT "planets"."id", "planets"."name", "planets"."galaxyID" FROM "planets" WHERE "planets"."galaxyID" IN ($1, $2)
        for galaxy in galaxies {
            print(galaxy.planets.get()) // [Planet]
        }
    }
    
    struct Failure: Error, CustomStringConvertible, LocalizedError {
        let reason: String
        
        var description: String {
            return self.reason
        }
        
        init(_ reason: String) {
            self.reason = reason
        }
    }
    
    public func testCreate() throws {
        try self.database.schema(Galaxy.self).auto().create().wait()
        
        let galaxy = Galaxy.new()
        galaxy.name.set(to: "Messier 82")
        try galaxy.save(on: self.database).wait()
        
        guard let fetched = try self.database.query(Galaxy.self).filter(\.name == "Messier 82").first().wait() else {
            throw Failure("unexpected empty result set")
        }
        
        if try fetched.name.get() != galaxy.name.get() {
            throw Failure("unexpected name: \(galaxy) \(fetched)")
        }
        if try fetched.id.get() != galaxy.id.get() {
            throw Failure("unexpected id: \(galaxy) \(fetched)")
        }
        
        try self.database.schema(Galaxy.self).delete().wait()
    }
}

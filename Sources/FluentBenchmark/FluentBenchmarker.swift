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
        try self.testCreate()
    }
    
    struct Failure: Error, CustomStringConvertible, LocalizedError {
        let reason: String
        
        var errorDescription: String? {
            return self.reason
        }
        
        var description: String {
            return self.reason
        }
        
        init(_ reason: String) {
            self.reason = reason
        }
    }
    
    public func testBasics() throws {
        try runTest(#function, [
            Galaxy.migration(on: self.database),
            GalaxySeed(on: self.database)
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
    
    public func testEagerLoad() throws {
        try runTest(#function, [
            Galaxy.migration(on: self.database),
            Planet.migration(on: self.database),
            GalaxySeed(on: self.database),
            PlanetSeed(on: self.database)
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
    
    public func testCreate() throws {
        try runTest(#function, [
            Galaxy.migration(on: self.database)
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
    
    private func runTest(_ name: String, _ migrations: [Migration], _ test: () throws -> ()) throws {
        print("[FluentBenchmark] Running \(name)...")
        for migration in migrations {
            try migration.prepare().wait()
        }
        var e: Error?
        do {
            try test()
        } catch {
            e = error
        }
        for migration in migrations {
            try migration.revert().wait()
        }
        if let error = e {
            throw error
        }
    }
}

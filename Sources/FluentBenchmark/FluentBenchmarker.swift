import Fluent
import Foundation

public final class FluentBenchmarker {
    public let database: FluentDatabase
    
    public init(database: FluentDatabase) {
        self.database = database
    }
    
    public func run() throws {
        try testBasics()
        try testEagerLoad()
    }
    
    func testBasics() throws {
        print("[BASIC]")
        let res = try database.query(Galaxy.self)
            .filter(\.name, .equal, "Milky Way")
            .all().wait()
        print(res)
    }
    
    func testEagerLoad() throws {
        print("[EAGER LOAD]")
        
        // SELECT "galaxies"."id", "galaxies"."name" FROM "galaxies"
        let galaxies = try database.query(Galaxy.self)
            .with(\.planets)
            .all().wait()
        print(galaxies) // [Galaxy]

        // SELECT "planets"."id", "planets"."name", "planets"."galaxyID" FROM "planets" WHERE "planets"."galaxyID" IN ($1, $2)
        for galaxy in galaxies {
            print(galaxy.planets.get()) // [Planet]
        }
    }
}

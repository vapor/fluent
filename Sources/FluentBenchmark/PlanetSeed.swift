import Fluent
import NIO

final class PlanetSeed: FluentMigration {
    init() { }
    
    func prepare(on database: FluentDatabase) -> EventLoopFuture<Void> {
        let milkyWay = self.add([
            "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"
        ], to: "Milky Way", on: database)
        let andromeda = self.add(["PA-99-N2"], to: "Andromeda", on: database)
        return .andAll([milkyWay, andromeda], eventLoop: database.eventLoop)
    }
    
    private func add(_ planets: [String], to galaxy: String, on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.query(Galaxy.self).filter(\.name == galaxy).first().flatMap { galaxy -> EventLoopFuture<Void> in
            guard let galaxy = galaxy else {
                return database.eventLoop.makeSucceededFuture(())
            }
            let saves = planets.map { name -> EventLoopFuture<Void> in
                let planet = Planet.new()
                planet.name.set(to: name)
                try! planet.galaxy.set(to: galaxy)
                return planet.save(on: database)
            }
            return .andAll(saves, eventLoop: database.eventLoop)
        }
    }
    
    func revert(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededFuture(())
    }
}

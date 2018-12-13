import Fluent
import NIO

final class PlanetSeed: Migration {
    let database: FluentDatabase
    
    init(on database: FluentDatabase) {
        self.database = database
    }
    
    func prepare() -> EventLoopFuture<Void> {
        let milkyWay = self.add(["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"], to: "Milky Way")
        let andromeda = self.add(["PA-99-N2"], to: "Andromeda")
        return .andAll([milkyWay, andromeda], eventLoop: self.database.eventLoop)
    }
    
    private func add(_ planets: [String], to galaxy: String) -> EventLoopFuture<Void> {
        return self.database.query(Galaxy.self).filter(\.name == galaxy).first().then { galaxy -> EventLoopFuture<Void> in
            guard let galaxy = galaxy else {
                return self.database.eventLoop.newSucceededFuture(result: ())
            }
            let saves = planets.map { name -> EventLoopFuture<Void> in
                let planet = Planet.new()
                planet.name.set(to: name)
                try! planet.galaxy.set(to: galaxy)
                return planet.save(on: self.database)
            }
            return .andAll(saves, eventLoop: self.database.eventLoop)
        }
    }
    
    func revert() -> EventLoopFuture<Void> {
        return self.database.eventLoop.newSucceededFuture(result: ())
    }
}

import Fluent
import NIO

final class GalaxySeed: FluentMigration {
    init() { }
    
    func prepare(on database: FluentDatabase) -> EventLoopFuture<Void> {
        let saves = ["Andromeda", "Milky Way", "Messier 82"].map { name -> EventLoopFuture<Void> in
            let galaxy = Galaxy.new()
            galaxy.name.set(to: name)
            return galaxy.save(on: database)
        }
        return .andAllSucceed(saves, on: database.eventLoop)
    }
    
    func revert(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededFuture(())
    }
}

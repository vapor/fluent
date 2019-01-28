import Fluent
import NIO

final class GalaxySeed: FluentMigration {
    let database: FluentDatabase
    
    init(on database: FluentDatabase) {
        self.database = database
    }
    
    func prepare() -> EventLoopFuture<Void> {
        let saves = ["Andromeda", "Milky Way", "Messier 82"].map { name -> EventLoopFuture<Void> in
            let galaxy = Galaxy.new()
            galaxy.name.set(to: name)
            return galaxy.save(on: self.database)
        }
        return .andAll(saves, eventLoop: self.database.eventLoop)
    }
    
    func revert() -> EventLoopFuture<Void> {
        return self.database.eventLoop.makeSucceededFuture(result: ())
    }
}

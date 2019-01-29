import Fluent
import NIO

final class ErrorMigration: FluentMigration {
    init() { }
    
    struct Error: Swift.Error { }
    
    func prepare(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.eventLoop.makeFailedFuture(Error())
    }
    
    func revert(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.eventLoop.makeSucceededFuture(())
    }
}

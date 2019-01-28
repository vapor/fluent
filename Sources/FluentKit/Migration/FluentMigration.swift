import NIO

public protocol FluentMigration {
    func prepare() -> EventLoopFuture<Void>
    func revert() -> EventLoopFuture<Void>
}

extension FluentModel {
    public static func migration(on database: FluentDatabase) -> FluentMigration {
        return AutoMigration<Self>(database: database)
    }
}

private final class AutoMigration<Model>: FluentMigration where Model: FluentKit.FluentModel {
    let database: FluentDatabase
    
    init(database: FluentDatabase) {
        self.database = database
    }
    
    func prepare() -> EventLoopFuture<Void> {
        return self.database.schema(Model.self).auto().create()
    }
    
    func revert() -> EventLoopFuture<Void> {
        return self.database.schema(Model.self).delete()
    }
}

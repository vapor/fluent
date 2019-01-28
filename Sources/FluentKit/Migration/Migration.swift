import NIO

public protocol Migration {
    func prepare() -> EventLoopFuture<Void>
    func revert() -> EventLoopFuture<Void>
}

extension Model {
    public static func migration(on database: FluentDatabase) -> Migration {
        return AutoMigration<Self>(database: database)
    }
}

final class AutoMigration<Model>: Migration where Model: FluentKit.Model {
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

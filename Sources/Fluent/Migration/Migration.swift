import NIO

public protocol Migration {
    func prepare() -> EventLoopFuture<Void>
    func revert() -> EventLoopFuture<Void>
}

extension Model {
    static func migration(database: FluentDatabase) -> Migration {
        return ModelMigration<Self>(database: database)
    }
}

final class ModelMigration<Model>: Migration where Model: Fluent.Model {
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

import NIO

public protocol FluentMigration {
    var name: String { get }
    func prepare(on database: FluentDatabase) -> EventLoopFuture<Void>
    func revert(on database: FluentDatabase) -> EventLoopFuture<Void>
}

extension FluentMigration {
    public var name: String {
        return "\(Self.self)"
    }
    
}

extension FluentModel {
    public static func autoMigration() -> FluentMigration {
        return AutoMigration<Self>()
    }
}

private final class AutoMigration<Model>: FluentMigration
    where Model: FluentKit.FluentModel
{
    init() { }
    var name: String {
        return "\(Model.self)"
    }
    
    func prepare(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.schema(Model.self).auto().create()
    }
    
    func revert(on database: FluentDatabase) -> EventLoopFuture<Void> {
        return database.schema(Model.self).delete()
    }
}

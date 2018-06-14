import Fluent

internal final class Foo<D>: Model where D: QuerySupporting {
    /// See Model.Database
    typealias Database = D

    /// See Model.ID
    typealias ID = UUID

    /// See Model.name
    static var name: String { return "foo" }

    /// See Model.idKey
    static var idKey: IDKey { return \.id }

    /// Foo's identifier
    var id: UUID?

    /// Test string
    var bar: String

    /// Test integer
    var baz: Int

    /// Create a new foo
    init(id: ID? = nil, bar: String, baz: Int) {
        self.id = id
        self.bar = bar
        self.baz = baz
    }
}

internal struct FooMigration<D>: Migration where D: QuerySupporting & SchemaSupporting & MigrationSupporting {
    /// See Migration.database
    typealias Database = D

    /// See Migration.prepare
    static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(Foo<Database>.self, on: connection) { builder in
            builder.field(for: \Foo<Database>.id)
            builder.field(for: \Foo<Database>.bar)
            builder.field(for: \Foo<Database>.baz)
        }
    }

    /// See Migration.revert
    static func revert(on connection: Database.Connection) -> Future<Void> {
        return Database.delete(Foo<Database>.self, on: connection)
    }
}

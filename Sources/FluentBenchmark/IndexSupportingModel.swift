import Async
import Fluent
import Foundation

public final class IndexSupportingModel<D>: Model, Migration where D: QuerySupporting, D: IndexSupporting {
    /// See Model.Database
    public typealias Database = D

    /// See Model.ID
    public typealias ID = UUID

    /// See Model.idKey
    public static var idKey: IDKey { return \.id }

    /// See Model.name
    public static var entity: String {
        return "index-supporting-model"
    }

    /// Foo's identifier
    var id: UUID?

    /// Name string
    var name: String

    /// Age int
    var age: Int

    /// Create a new foo
    init(id: ID? = nil, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }

    /// See Migration.prepare
    public static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addIndex(to: \.name, \.age, isUnique: true)
            try builder.addIndex(to: \.name)
            try builder.addIndex(to: \.age)
        }
    }
}

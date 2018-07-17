struct Galaxy<Database>: Model, Equatable where Database: QuerySupporting {
    typealias ID = UUID
    static var idKey: IDKey { return \.id }
    var id: UUID?
    var name: String
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Galaxy: AnyMigration, Migration where
    Database: SchemaSupporting & MigrationSupporting { }

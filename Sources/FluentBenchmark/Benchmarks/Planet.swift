struct Planet<Database>: Model, Equatable where Database: QuerySupporting {
    typealias ID = UUID
    static var idKey: IDKey { return \.id }
    var id: UUID?
    var name: String
    var galaxyID: UUID
    
    var galaxy: Parent<Planet<Database>, Galaxy<Database>> {
        return parent(\.galaxyID)
    }
    
    init(id: UUID? = nil, name: String, galaxyID: UUID) {
        self.id = id
        self.name = name
        self.galaxyID = galaxyID
    }
}

extension Planet: AnyMigration, Migration where
    Database: SchemaSupporting & MigrationSupporting { }

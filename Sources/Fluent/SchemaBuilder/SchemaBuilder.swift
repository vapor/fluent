import NIO

extension FluentDatabase {
    public func schema<Model>(_ model: Model.Type) -> SchemaBuilder<Model>
        where Model: Fluent.Model
    {
        return .init(database: self)
    }
}

public final class SchemaBuilder<Model> where Model: Fluent.Model {
    let database: FluentDatabase
    public var schema: DatabaseSchema
    
    public init(database: FluentDatabase) {
        self.database = database
        self.schema = .init(entity: Model.new().entity)
    }
    
    public func auto() -> Self {
        self.schema.createFields = Model.new().properties.map { field in
            return .definition(
                name: .string(field.name),
                dataType: field.dataType ?? .bestFor(type: field.type),
                constraints: field.constraints
            )
        }
        return self
    }
    
    public func field<Model, Value>(_ keyPath: KeyPath<Model, ModelField<Model, Value>>) -> Self {
        let field = Model.new()[keyPath: keyPath]
        return self.field(.definition(
            name: .string(field.name),
            dataType: field.dataType ?? .bestFor(type: Value.self),
            constraints: field.constraints
        ))
    }
    
    public func field(_ field: DatabaseSchema.FieldDefinition) -> Self {
        self.schema.createFields.append(field)
        return self
    }
    
    public func deleteField(_ name: String) -> Self {
        return self.deleteField(.string(name))
    }
    
    public func deleteField(_ name: DatabaseSchema.FieldName) -> Self {
        self.schema.deleteFields.append(name)
        return self
    }
    
    public func delete() -> EventLoopFuture<Void> {
        self.schema.action = .delete
        return self.database.execute(self.schema)
    }
    
    public func update() -> EventLoopFuture<Void> {
        self.schema.action = .update
        return self.database.execute(self.schema)
    }
    
    public func create() -> EventLoopFuture<Void> {
        self.schema.action = .create
        return self.database.execute(self.schema)
    }
}

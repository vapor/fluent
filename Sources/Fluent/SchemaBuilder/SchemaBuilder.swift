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
        self.schema = .init(entity: Model.ref.entity)
    }
    
    public func auto() -> Self {
        self.schema.createFields = Model.new().properties.map { field in
            return .definition(.init(
                name: field.name,
                dataType: field.dataType ?? .bestFor(type: field.type),
                isIdentifier: field.isIdentifier
            ))
        }
        return self
    }
    
    public func field<Model, Value>(_ keyPath: KeyPath<Model, ModelField<Model, Value>>) -> Self {
        let field = Model.ref[keyPath: keyPath]
        let definition = DatabaseSchema.Field.Definition.init(
            name: field.name,
            dataType: field.dataType ?? .bestFor(type: Value.self),
            isIdentifier: field.isIdentifier
        )
        return self.field(.definition(definition))
    }
    
    public func field(_ field: DatabaseSchema.Field) -> Self {
        self.schema.createFields.append(field)
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

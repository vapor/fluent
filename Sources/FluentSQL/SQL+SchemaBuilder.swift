extension SchemaBuilder where
    Model.Database.Schema: FluentSQLSchema,
    Model.Database.SchemaField == Model.Database.Schema.ColumnDefinition
{
    public func field<T>(
        for key: KeyPath<Model, T>,
        type: Model.Database.Schema.ColumnDefinition.DataType,
        _ constraints: Model.Database.Schema.ColumnDefinition.ColumnConstraint...
    ) {
        let property = FluentProperty.keyPath(key)
        self.field(.columnDefinition(.column(nil, .identifier(property.path[0])), type, constraints))
    }
}

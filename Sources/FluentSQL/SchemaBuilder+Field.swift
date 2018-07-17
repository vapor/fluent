extension SchemaBuilder where
    Model.Database.Schema: FluentSQLSchema,
    Model.Database.SchemaField == Model.Database.Schema.ColumnDefinition
{
    /// Adds a field with specified type and constraints.
    ///
    ///     builder.field(for: \.name, type: ..., ...)
    ///
    /// - parameters:
    ///     - key: `KeyPath` to the field.
    ///     - type: Data type to use for this field.
    ///     - constraints: Constraints to apply to this field.
    public func field<T>(
        for key: KeyPath<Model, T>,
        type: Model.Database.Schema.ColumnDefinition.DataType,
        _ constraints: Model.Database.Schema.ColumnDefinition.ColumnConstraint...
    ) {
        let property = FluentProperty.keyPath(key)
        self.field(.columnDefinition(.column(nil, .identifier(property.path[0])), type, [.notNull] + constraints))
    }
    
    /// Adds a field with specified type and constraints.
    ///
    ///     builder.field(for: \.name, type: ..., ...)
    ///
    /// - parameters:
    ///     - key: `KeyPath` to the field.
    ///     - type: Data type to use for this field.
    ///     - constraints: Constraints to apply to this field.
    public func field<T>(
        for key: KeyPath<Model, T?>,
        type: Model.Database.Schema.ColumnDefinition.DataType,
        _ constraints: Model.Database.Schema.ColumnDefinition.ColumnConstraint...
    ) {
        let property = FluentProperty.keyPath(key)
        self.field(.columnDefinition(.column(nil, .identifier(property.path[0])), type, constraints))
    }
}

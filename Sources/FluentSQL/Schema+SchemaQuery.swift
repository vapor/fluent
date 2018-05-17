extension Schema where Database: CustomSQLSupporting {
    /// Converts a database schema to sql schema query
    public func convertToSchemaQuery(dataTypeFactory: (Schema<Database>.FieldDefinition) throws -> String) throws -> DataDefinitionQuery {
        switch action {
        case .create:
            return try .init(
                statement: .create,
                table: entity,
                addColumns: addFields.map { try convertToSchemaColumn($0, dataType: dataTypeFactory($0)) },
                addForeignKeys: []
            )
        case .update:
            return try .init(
                statement: .alter,
                table: entity,
                addColumns: addFields.map { try convertToSchemaColumn($0, dataType: dataTypeFactory($0)) },
                removeColumns: removeFields.map { try $0.convertToDataColumn().name },
                addForeignKeys: [],
                removeForeignKeys: []
            )
        case .delete: return .init(statement: .drop, table: entity)
        }
    }

    /// Convert a schema field to a sql schema column.
    private  func convertToSchemaColumn(_ field: Schema.FieldDefinition, dataType: String) throws -> DataDefinitionColumn {
        return try .init(name: field.field.convertToDataColumn().name, dataType: dataType)
    }
}

extension Schema where Database: CustomSQLSupporting & ReferenceSupporting {
    /// Converts a database schema to sql schema query
    public func applyReferences(to schemaQuery: inout DataDefinitionQuery) throws {
        switch schemaQuery.statement {
        case .create:
            schemaQuery.addForeignKeys = try convertToAddForeignKeys(self)
        case .alter:
            schemaQuery.addForeignKeys = try convertToAddForeignKeys(self)
            schemaQuery.removeForeignKeys = try convertToRemoveForeignKeys(self)
        default: break
        }
    }

    // MARK: Private

    /// Convert schema references to a sql foreign key
    private func convertToAddForeignKeys(_ scheme: Schema)  throws-> [DataDefinitionForeignKey] {
        return try scheme.addReferences.map { try convertToForeignKey($0) }
    }

    /// Convert schema references to a sql foreign key
    private func convertToRemoveForeignKeys(_ scheme: Schema) throws -> [String] {
        return try scheme.removeReferences.map { try sqlName(for: $0) }
    }

    private func sqlName(for reference: Schema.Reference) throws -> String {
        let base = try reference.base.convertToDataColumn()
        let referenced = try reference.base.convertToDataColumn()
        return "\(base.table ?? "").\(base.name)_\(referenced.table ?? "").\(referenced.name)"
    }

    /// Convert a schema reference to a sql foreign key
    private func convertToForeignKey(_ reference: Schema.Reference) throws -> DataDefinitionForeignKey {
        return try .init(
            name: sqlName(for: reference),
            local: reference.base.convertToDataColumn(),
            foreign: reference.referenced.convertToDataColumn(),
            onUpdate: reference.actions.update.flatMap { self.convertToForeignKeyAction($0) },
            onDelete: reference.actions.delete.flatMap { self.convertToForeignKeyAction($0) }
        )
    }
    /// Converts a `ReferentialAction` to `SchemaForeignKeyAction`
    private func convertToForeignKeyAction(_ action: Schema.Reference.ActionType) -> DataDefinitionForeignKeyAction {
        switch action {
        case .nullify: return .setNull
        case .prevent: return .restrict
        case .update: return .cascade
        }
    }
}

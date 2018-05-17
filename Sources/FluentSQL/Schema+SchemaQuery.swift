extension Schema where Database: SQLDatabase {
    /// Converts a database schema to sql schema query
    public func convertToDataDefinitionQuery() throws -> DataDefinitionQuery {
        let definition: DataDefinitionQuery
        switch action {
        case .create:
            definition = .init(
                statement: .create,
                table: entity,
                addColumns: addFields.map { $0.convertToDataDefinitionColumn() },
                addForeignKeys: []
            )
        case .update:
            definition = .init(
                statement: .alter,
                table: entity,
                addColumns: addFields.map { $0.convertToDataDefinitionColumn() },
                removeColumns: removeFields.map { $0.name },
                addForeignKeys: [],
                removeForeignKeys: []
            )
        case .delete: definition = .init(statement: .drop, table: entity)
        }
        return definition
    }
}

extension Schema where Database: SQLDatabase & ReferenceSupporting {
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
        let base = reference.base
        let referenced = reference.base
        return "\(base.table ?? "").\(base.name)_\(referenced.table ?? "").\(referenced.name)"
    }

    /// Convert a schema reference to a sql foreign key
    private func convertToForeignKey(_ reference: Schema.Reference) throws -> DataDefinitionForeignKey {
        return try .init(
            name: sqlName(for: reference),
            local: reference.base,
            foreign: reference.referenced,
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

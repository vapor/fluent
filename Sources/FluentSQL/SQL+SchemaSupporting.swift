extension SchemaSupporting where SchemaAction: FluentSQLSchemaStatement {
    /// See `SchemaSupporting`.
    public static var schemaActionCreate: SchemaAction {
        return .createTable
    }
    
    /// See `SchemaSupporting`.
    public static var schemaActionUpdate: SchemaAction {
        return .alterTable
    }
    
    /// See `SchemaSupporting`.
    public static var schemaActionDelete: SchemaAction {
        return .dropTable
    }
}

extension SchemaSupporting where Schema: FluentSQLSchema, SchemaAction == Schema.Statement {
    /// See `SchemaSupporting`.
    public static func schemaCreate(_ action: SchemaAction, _ entity: String) -> Schema {
        return .schema(action, .table(.identifier(entity)))
    }
}

extension SchemaSupporting where
    SchemaField: SQLColumnDefinition,
    SchemaFieldType == SchemaField.DataType,
    QueryField == SchemaField.ColumnIdentifier
{
    /// See `SchemaSupporting`.
    public static func schemaField(_ field: QueryField, _ type: SchemaFieldType) -> SchemaField {
        return .columnDefinition(field, type, [])
    }
}

extension SchemaSupporting where Schema: FluentSQLSchema, SchemaField == Schema.ColumnDefinition {
    /// See `SchemaSupporting`.
    public static func schemaFieldCreate(_ field: SchemaField, to query: inout Schema) {
        query.columns.append(field)
    }
}

extension SchemaSupporting where Schema: FluentSQLSchema, QueryField == Schema.ColumnIdentifier {
    /// See `SchemaSupporting`.
    public static func schemaFieldDelete(_ field: QueryField, to query: inout Schema) {
        query.deleteColumns.append(field)
    }
}


extension SchemaSupporting where Schema: FluentSQLSchema, SchemaConstraint == Schema.TableConstraint {
    /// See `SchemaSupporting`.
    public static func schemaConstraintCreate(_ constraint: SchemaConstraint, to query: inout Schema) {
        query.constraints.append(constraint)
    }
    
    /// See `SchemaSupporting`.
    public static func schemaConstraintDelete(_ constraint: SchemaConstraint, to query: inout Schema) {
        query.deleteConstraints.append(constraint)
    }
}

public protocol SQLConstraintIdentifierNormalizer {
    static func normalizeSQLConstraintIdentifier(_ identifier: String) -> String
}

extension SchemaSupporting where
    SchemaConstraint: SQLTableConstraint,
    QueryField: SQLColumnIdentifier,
    QueryField.Identifier == SchemaConstraint.Algorithm.Identifier,
    SchemaReferenceAction == SchemaConstraint.Algorithm.ForeignKey.Action,
    QueryField.TableIdentifier == SchemaConstraint.Algorithm.ForeignKey.TableIdentifier,
    QueryField.Identifier == SchemaConstraint.Algorithm.ForeignKey.Identifier,
    Self: SQLConstraintIdentifierNormalizer
{
    /// See `SchemaSupporting`.
    public static func schemaReference(from: QueryField, to: QueryField, onUpdate: SchemaReferenceAction?, onDelete: SchemaReferenceAction?) -> SchemaConstraint {
        guard let foreignTable = to.table else {
            fatalError("Cannot create reference to column without table identifier: \(to).")
        }
        guard let localTable = from.table else {
            fatalError("Cannot create reference from column without table identifier: \(from).")
        }
        let uid = "\(localTable.identifier.string).\(from.identifier.string)+\(foreignTable.identifier.string).\(to.identifier.string)"
        return .constraint(
            .foreignKey([from.identifier], .foreignKey(foreignTable, [to.identifier], onDelete: onDelete, onUpdate: onUpdate)),
            .identifier("fk:\(normalizeSQLConstraintIdentifier(uid))")
        )
    }
}

extension SchemaSupporting where
    SchemaConstraint: SQLTableConstraint,
    QueryField: SQLColumnIdentifier,
    QueryField.Identifier == SchemaConstraint.Algorithm.Identifier,
    Self: SQLConstraintIdentifierNormalizer
{
    /// See `SchemaSupporting`.
    public static func schemaUnique(on: [QueryField]) -> SchemaConstraint {
        let uid = on.map {
            guard let table = $0.table else {
                fatalError("Cannot create unique constraint on column without table identifier: \($0).")
            }
            return "\(table.identifier.string).\($0.identifier.string)"
        }.joined(separator: "+")
        return .constraint(.unique(on.map { $0.identifier }), .identifier("uq:\(normalizeSQLConstraintIdentifier(uid))"))
    }
}

extension SchemaSupporting {
    
}

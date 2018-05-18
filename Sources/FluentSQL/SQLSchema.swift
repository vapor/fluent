public protocol SQLSchema: Schema where
    Action: DataDefinitionStatementRepresentable,
    Field: DataColumnRepresentable,
    FieldDefinition: DataDefinitionColumnRepresentable,
    Reference: DataDefinitionForeignKeyRepresentable
{
    var table: String { get set }
    var statement: Action { get set }
    var createColumns: [FieldDefinition] { get set }
    var deleteColumns: [Field] { get set }
    var createForeignKeys: [Reference] { get set }
    var deleteForeignKeys: [Reference] { get set }
}

extension SQLSchema {
    public static var fluentActionKey: WritableKeyPath<Self, Action> {
        return \.statement
    }

    public static var fluentCreateFieldsKey: WritableKeyPath<Self, [FieldDefinition]> {
        return \.createColumns
    }

    public static var fluentDeleteFieldsKey: WritableKeyPath<Self, [Field]> {
        return \.deleteColumns
    }

    public static var fluentCreateReferencesKey: WritableKeyPath<Self, [Reference]> {
        return \.createForeignKeys
    }

    public static var fluentDeleteReferencesKey: WritableKeyPath<Self, [Reference]> {
        return \.deleteForeignKeys
    }

    /// Converts a database schema to sql schema query
    public func convertToDataDefinitionQuery() throws -> DataDefinitionQuery {
        return .init(
            statement: statement.convertToDataDefinitionStatement(),
            table: table,
            addColumns: createColumns.map { $0.convertToDataDefinitionColumn() },
            removeColumns: deleteColumns.map { $0.convertToDataColumn().name },
            addForeignKeys: createForeignKeys.map { $0.convertToDataDefinitionForeignKey() },
            removeForeignKeys: deleteForeignKeys.map { $0.convertToDataDefinitionForeignKey().name }
        )
    }
}


public protocol DataColumnRepresentable {
    func convertToDataColumn() -> DataColumn
}
extension DataColumn: DataColumnRepresentable {
    public func convertToDataColumn() -> DataColumn {
        return self
    }
}

public protocol DataDefinitionForeignKeyRepresentable {
    func convertToDataDefinitionForeignKey() -> DataDefinitionForeignKey
}
extension DataDefinitionForeignKey: DataDefinitionForeignKeyRepresentable {
    public func convertToDataDefinitionForeignKey() -> DataDefinitionForeignKey {
        return self
    }
}

public protocol DataDefinitionColumnRepresentable {
    func convertToDataDefinitionColumn() -> DataDefinitionColumn
}
extension DataDefinitionColumn: DataDefinitionColumnRepresentable {
    public func convertToDataDefinitionColumn() -> DataDefinitionColumn {
        return self
    }
}

public protocol DataDefinitionStatementRepresentable {
    func convertToDataDefinitionStatement() -> DataDefinitionStatement
}
extension DataDefinitionStatement: DataDefinitionStatementRepresentable {
    public func convertToDataDefinitionStatement() -> DataDefinitionStatement {
        return self
    }
}

//extension DataDefinitionColumn: SchemaFieldDefinition {
//    public static func fluentFieldDefinition(_ field: DataColumn, _ dataType: String, isIdentifier: Bool) -> DataDefinitionColumn {
//        return  DataDefinitionColumn.init(name: field.name, dataType: dataType, attributes: isIdentifier ? ["PRIMARY KEY"] : [])
//    }
//
//    public typealias Field = DataColumn
//    public typealias DataType = String
//}
//
//extension String: SchemaDataType {
//    public static func fluentType(_ type: Any.Type) -> String {
//        return "FOO"
//    }
//}

extension DataDefinitionStatement: SchemaAction {
    public static var fluentCreate: DataDefinitionStatement {
        return .create
    }

    public static var fluentUpdate: DataDefinitionStatement {
        return .alter
    }

    public static var fluentDelete: DataDefinitionStatement {
        return .drop
    }
}

extension DataDefinitionForeignKey: SchemaReference {
    public static func fluentReference(base: DataColumn, referenced: DataColumn, actions: DataDefinitionForeignKeyActions) -> DataDefinitionForeignKey {
        let name = "\(base.table ?? "").\(base.name)_\(referenced.table ?? "").\(referenced.name)"
        return .init(name: name, local: base, foreign: referenced, onUpdate: actions.onUpdate, onDelete: actions.onDelete)
    }

    public typealias Actions = DataDefinitionForeignKeyActions
    public typealias Field = DataColumn
}

public struct DataDefinitionForeignKeyActions: SchemaReferenceActions {
    public static var `default`: DataDefinitionForeignKeyActions { return
        DataDefinitionForeignKeyActions.init(onUpdate: .restrict, onDelete: .restrict)
    }

    public typealias ActionType = DataDefinitionForeignKeyAction

    var onUpdate: DataDefinitionForeignKeyAction?
    var onDelete: DataDefinitionForeignKeyAction?
}


//extension Schema where Database: SQLDatabase & ReferenceSupporting {
//    /// Converts a database schema to sql schema query
//    public func applyReferences(to schemaQuery: inout DataDefinitionQuery) throws {
//        switch schemaQuery.statement {
//        case .create:
//            schemaQuery.addForeignKeys = try convertToAddForeignKeys(self)
//        case .alter:
//            schemaQuery.addForeignKeys = try convertToAddForeignKeys(self)
//            schemaQuery.removeForeignKeys = try convertToRemoveForeignKeys(self)
//        default: break
//        }
//    }
//
//    // MARK: Private
//
//    /// Convert schema references to a sql foreign key
//    private func convertToAddForeignKeys(_ scheme: Schema)  throws-> [DataDefinitionForeignKey] {
//        return try scheme.addReferences.map { try convertToForeignKey($0) }
//    }
//
//    /// Convert schema references to a sql foreign key
//    private func convertToRemoveForeignKeys(_ scheme: Schema) throws -> [String] {
//        return try scheme.removeReferences.map { try sqlName(for: $0) }
//    }
//
//    private func sqlName(for reference: Schema.Reference) throws -> String {
//        let base = reference.base
//        let referenced = reference.base
//        return "\(base.table ?? "").\(base.name)_\(referenced.table ?? "").\(referenced.name)"
//    }
//
//    /// Convert a schema reference to a sql foreign key
//    private func convertToForeignKey(_ reference: Schema.Reference) throws -> DataDefinitionForeignKey {
//        return try .init(
//            name: sqlName(for: reference),
//            local: reference.base,
//            foreign: reference.referenced,
//            onUpdate: reference.actions.update.flatMap { self.convertToForeignKeyAction($0) },
//            onDelete: reference.actions.delete.flatMap { self.convertToForeignKeyAction($0) }
//        )
//    }
//    /// Converts a `ReferentialAction` to `SchemaForeignKeyAction`
//    private func convertToForeignKeyAction(_ action: Schema.Reference.ActionType) -> DataDefinitionForeignKeyAction {
//        switch action {
//        case .nullify: return .setNull
//        case .prevent: return .restrict
//        case .update: return .cascade
//        }
//    }
//}

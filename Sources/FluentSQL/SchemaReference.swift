import Fluent
import SQL

extension DatabaseSchema where Database: ReferenceSupporting {
    /// Convert schema references to a sql foreign key
    public func makeAddForeignKeys() -> [SchemaForeignKey] {
        return addReferences.map { $0.makeForeignKey() }
    }

    /// Convert schema references to a sql foreign key
    public func makeRemoveForeignKeys() -> [String] {
        return removeReferences.map { $0.sqlName }
    }
}

extension SchemaReference {
    fileprivate var sqlName: String {
        return "\(base.entity ?? "").\(base.name)_\(referenced.entity ?? "").\(referenced.name)"
    }

    /// Convert a schema reference to a sql foreign key
    fileprivate func makeForeignKey() -> SchemaForeignKey {
        return SchemaForeignKey(
            name: sqlName,
            local: DataColumn(table: nil, name: base.name),
            foreign: referenced.makeDataColumn(),
            onUpdate: actions.update?.makeForeignKeyAction(),
            onDelete: actions.delete?.makeForeignKeyAction()
        )
    }
}

extension ReferentialAction {
    /// Converts a `ReferentialAction` to `SchemaForeignKeyAction`
    fileprivate func makeForeignKeyAction() -> SchemaForeignKeyAction {
        switch self {
        case .nullify: return .setNull
        case .prevent: return .restrict
        case .update: return .cascade
        }
    }
}

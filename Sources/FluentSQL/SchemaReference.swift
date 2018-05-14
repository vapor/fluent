import Fluent
import SQL

extension DatabaseSchema where Database: ReferenceSupporting, Database.QueryField: DataColumnRepresentable  {
    /// Convert schema references to a sql foreign key
    public func makeAddForeignKeys() -> [DataDefinitionForeignKey] {
        return addReferences.map { $0.makeForeignKey() }
    }

    /// Convert schema references to a sql foreign key
    public func makeRemoveForeignKeys() -> [String] {
        return removeReferences.map { $0.sqlName }
    }
}

extension SchemaReference where Database: QuerySupporting, Database.QueryField: DataColumnRepresentable  {
    fileprivate var sqlName: String {
        let base = self.base.makeDataColumn()
        let referenced = self.base.makeDataColumn()
        return "\(base.table ?? "").\(base.name)_\(referenced.table ?? "").\(referenced.name)"
    }

    /// Convert a schema reference to a sql foreign key
    fileprivate func makeForeignKey() -> DataDefinitionForeignKey {
        return .init(
            name: sqlName,
            local: base.makeDataColumn(),
            foreign: referenced.makeDataColumn(),
            onUpdate: actions.update?.makeForeignKeyAction(),
            onDelete: actions.delete?.makeForeignKeyAction()
        )
    }
}

extension ReferentialAction {
    /// Converts a `ReferentialAction` to `SchemaForeignKeyAction`
    fileprivate func makeForeignKeyAction() -> DataDefinitionForeignKeyAction {
        switch self {
        case .nullify: return .setNull
        case .prevent: return .restrict
        case .update: return .cascade
        }
    }
}

import Fluent
import SQL

extension DatabaseSchema where Database: ReferenceSupporting {
    /// Convert schema references to a sql foreign key
    public func makeForeignKeys() -> [SchemaForeignKey] {
        return addReferences.map { $0.makeForeignKey() }
    }
}

extension SchemaReference {
    /// Convert a schema reference to a sql foreign key
    fileprivate func makeForeignKey() -> SchemaForeignKey {
        return SchemaForeignKey(
            name: "",
            local: DataColumn(table: nil, name: base.name),
            foreign: referenced.makeDataColumn()
        )
    }
}

public class SchemaTableBuilder {
	public typealias Handler = (SchemaTableBuilder) -> Void

	public enum `Type` {
		case Create
		case Alter
	}

	public let table: SchemaTable
	public let type: Type

	public private(set) var addColumns = Array<SchemaColumn>()
	public private(set) var dropColumns = Array<SchemaColumn>()
	public private(set) var addIndexes = Array<SchemaIndex>()
	public private(set) var dropIndexes = Array<SchemaIndex>()

	public init(table: SchemaTable, type: Type) {
		self.table = table
		self.type = type
	}

	public func addColumn(name: String, type: SchemaColumn.`Type`, nullable: Bool? = nil, index: SchemaIndex.`Type`? = nil) {
		let column = SchemaColumn(name: name)
		column.type = type
		column.nullable = nullable

		if let index = index {
			// New SchemaColumn instance to avoid cyclical reference
			column.indexes = [ SchemaIndex(type: index, columns: [ SchemaColumn(name: name) ]) ]
		}

		self.addColumn(column)
	}

	public func addColumn(column: SchemaColumn) {
		self.addColumns.append(column)
	}

	public func dropColumn(name: String) {
		self.dropColumn(SchemaColumn(name: name))
	}

	public func dropColumn(column: SchemaColumn) {
		assert(self.type != .Create, "You can not drop columns while creating a table.")
		self.dropColumns.append(column)
	}

	public func addIndex(name: String? = nil, type: SchemaIndex.`Type`, columns: [String]) {
		self.addIndex(name, type: type, columns: columns.map { return SchemaColumn(name: $0) })
	}

	public func addIndex(name: String? = nil, type: SchemaIndex.`Type`, columns: [SchemaColumn]) {
		self.addIndex(SchemaIndex(name: name, type: type, columns: columns))
	}

	public func addIndex(index: SchemaIndex) {
		self.addIndexes.append(index)
	}

	public func dropIndex(name: String) {
		self.dropIndex(SchemaIndex(name: name, type: .Primary, columns: []))
	}

	public func dropIndex(type: SchemaIndex.`Type`, columns: [SchemaColumn]) {
		self.dropIndex(SchemaIndex(name: nil, type: type, columns: columns))
	}

	public func dropIndex(index: SchemaIndex) {
		assert(self.type != .Create, "You can not drop indexes while creating a table.")
		self.dropIndexes.append(index)
	}

}

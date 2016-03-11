public protocol Driver {
	func fetchOne(table table: String, filters: [Filter]) -> [String: String]?
	func fetch(table table: String, filters: [Filter]) -> [[String: String]]
	func delete(table table: String, filters: [Filter])
	func update(table table: String, filters: [Filter], data: [String: String])
	func insert(table table: String, items: [[String: String]])
	func upsert(table table: String, items: [[String: String]])
	func exists(table table: String, filters: [Filter]) -> Bool
	func count(table table: String, filters: [Filter]) -> Int

	func create(table table: String, ifNotExists: Bool, builder: SchemaTableBuilder)
	func alter(table table: String, builder: SchemaTableBuilder)
	func rename(table table: String, to: String)
	func drop(table table: String, ifExists: Bool)
}

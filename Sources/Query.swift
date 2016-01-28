class Query {
	var table: String

	enum Operation {
		case Get, Save, Delete
	}
	var operation: Operation

	var id: String?
	var data: [String: String]?

	init(table: String, operation: Operation) {
		self.table = table
		self.operation = operation
	}
}
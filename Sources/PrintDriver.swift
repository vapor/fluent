class PrintDriver: Driver {

	func fetchOne(table table: String, filters: [Filter]) -> [String: String]? {
		print("Fetch One")
		print("\ttable: \(table)")
		print("\t\(filters.count) filters")

		return nil
	}

	func fetch(table table: String, filters: [Filter]) -> [[String: String]] {
		print("Fetch")
		print("\ttable: \(table)")
		print("\t\(filters.count) filters")

		return []
	}

	func delete(table table: String, filters: [Filter]) {
		print("Delete")
		print("\ttable: \(table)")
		print("\t\(filters.count) filters")

		return []
	}

	func update(table table: String, filters: [Filter], data: [String: String]) {
		print("Update")
		print("\ttable: \(table)")
		print("\t\(filters.count) filters")
		print("\t\(data.count) data points")

		return []
	}

	func insert(table table: String, items: [[String: String]]) {
		print("Insert")
		print("\ttable: \(table)")
		print("\t\(items.count) items")

		return []
	}

}
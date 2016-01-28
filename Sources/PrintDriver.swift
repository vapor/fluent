class PrintDriver: Driver {

	func fetchOne(table table: String, filters: [Filter]) -> [String: String]? {
		print("Fetch One")
		print("\ttable: \(table)")
		self.printFilters(filters)

		return nil
	}

	func fetch(table table: String, filters: [Filter]) -> [[String: String]] {
		print("Fetch")
		print("\ttable: \(table)")
		self.printFilters(filters)

		return []
	}

	func delete(table table: String, filters: [Filter]) {
		print("Delete")
		print("\ttable: \(table)")
		self.printFilters(filters)
	}

	func update(table table: String, filters: [Filter], data: [String: String]) {
		print("Update")
		print("\ttable: \(table)")
		self.printFilters(filters)
		print("\t\(data.count) data points")
		for (key, value) in data {
			print("\t\t\(key)=\(value)")
		}
	}

	func insert(table table: String, items: [[String: String]]) {
		print("Insert")
		print("\ttable: \(table)")
		print("\t\(items.count) items")
		for (key, item) in items.enumerate() {
			print("\t\titem \(key)")
			for (key, val) in item {
				print("\t\t\t\(key)=\(val)")
			}
		}
	}

	func printFilters(filters: [Filter]) {
		print("\t\(filters.count) filter(s)")
		for filter in filters {
			if let filter = filter as? ValueFilter {
				print("\t\t\(filter.key)=\(filter.value)")
			}
		}
	}

}
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

	func upsert(table table: String, items: [[String: String]]) {
		print("Upsert")
		print("\ttable: \(table)")
		print("\t\(items.count) items")
		for (key, item) in items.enumerate() {
			print("\t\titem \(key)")
			for (key, val) in item {
				print("\t\t\t\(key)=\(val)")
			}
		}

	}
	func exists(table table: String, filters: [Filter]) -> Bool {
		print("Exists")
		print("\ttable: \(table)")
		self.printFilters(filters)

		return false
	}

	func count(table table: String, filters: [Filter]) -> Int {
		print("Count")
		print("\ttable: \(table)")
		self.printFilters(filters)

		return 0
	}

	func printFilters(filters: [Filter]) {
		print("\t\(filters.count) filter(s)")
		for filter in filters {
			if let filter = filter as? CompareFilter {
				let symbol: String
				switch filter.comparison {
					case .Equals:
						symbol = "="
					case .NotEquals:
						symbol = "!="
					case .GreaterThan:
						symbol = ">"
					case .LessThan:
						symbol = "<"
					case .GreaterThanOrEquals:
						symbol = ">="
					case .LessThanOrEquals:
						symbol = "<="
				}

				print("\t\t\(filter.key) \(symbol) \(filter.value)")
			} else if let filter = filter as? SubsetFilter {
				let op: String
				switch filter.comparison {
					case .In:
						op = "in"
					case .NotIn:
						op = "not in"
				}

				print("\t\t\(filter.key) \(op) \(filter.superSet.count) options")
			}
		}
	}

}
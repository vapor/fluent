class Query {

	static var driver: Driver = MemoryDriver()

	var filters: [Filter] = []

	//ends
	func first() -> [String: String]? {
		guard let table = self.table else {
			return nil
		}

		return Query.driver.fetchOne(table: table, filters: self.filters)
	}

	func find() -> [[String: String]] {
		guard let table = self.table else {
			return []
		}

		return Query.driver.fetch(table: table, filters: self.filters)
	}

	func update(data: [String: String]) {
		guard let table = self.table else {
			return
		}

		Query.driver.update(table: table, filters: self.filters, data: data)
	}

	func insert(data: [String: String]) {
		guard let table = self.table else {
			return
		}

		Query.driver.insert(table: table, items: [data])
	}

	func insert(data: [[String: String]]) {
		guard let table = self.table else {
			return
		}

		Query.driver.insert(table: table, items: data)
	}

	func delete() {
		guard let table = self.table else {
			return
		}

		Query.driver.delete(table: table, filters: self.filters)
	}


	//continues
	func filter(key: String,_ value: String) -> Query {
		let filter = ValueFilter(key: key, value: value)
		self.filters.append(filter)

		return self
	}

	func table(table: String) -> Query {
		self.table = table
		return self
	}

	init() {

	}

	var table: String?
}
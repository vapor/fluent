class Query {

	static var driver: Driver = PrintDriver()

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
	func filter(key: String, _ value: String) -> Query {
		let filter = CompareFilter(key: key, value: value, comparison: .Equal)
		self.filters.append(filter)

		return self
	}

	func filter(key: String, _ comparison: CompareFilter.Comparison, _ value: String) -> Query {
		let filter = CompareFilter(key: key, value: value, comparison: comparison)
		self.filters.append(filter)

		return self
	}

	func filter(key: String, in superSet: [String]) -> Query {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .In)
		self.filters.append(filter)

		return self
	}

	func filter(key: String, notIn superSet: [String]) -> Query {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .NotIn)
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
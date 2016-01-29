public class Query {

	public static var driver: Driver = PrintDriver()

	public var filters: [Filter] = []

	typealias ModelSerializer = ([String: String]) -> Model
	var map: ModelSerializer?

	//ends
	//var first: Model?
	public var first: [String: String]? {
		guard let table = self.table else {
			return nil
		}

		return Query.driver.fetchOne(table: table, filters: self.filters)
	}

	//var results: [Model]
	public var results: [[String: String]] {
		guard let table = self.table else {
			return []
		}

		return Query.driver.fetch(table: table, filters: self.filters)
	}

	public func update(data: [String: String]) {
		guard let table = self.table else {
			return
		}

		Query.driver.update(table: table, filters: self.filters, data: data)
	}

	public func insert(data: [String: String]) {
		guard let table = self.table else {
			return
		}

		Query.driver.insert(table: table, items: [data])
	}

	public func upsert(data: [[String: String]]) {
		guard let table = self.table else {
			return
		}

		Query.driver.upsert(table: table, items: data)
	}

	public func upsert(data: [String: String]) {
		guard let table = self.table else {
			return
		}

		Query.driver.upsert(table: table, items: [data])
	}

	public func insert(data: [[String: String]]) {
		guard let table = self.table else {
			return
		}

		Query.driver.insert(table: table, items: data)
	}

	public func delete() {
		guard let table = self.table else {
			return
		}

		Query.driver.delete(table: table, filters: self.filters)
	}

	public var exists: Bool{
		guard let table = self.table else {
			return false
		}

		return Query.driver.exists(table: table, filters: self.filters)
	}

	public var count: Int {
		guard let table = self.table else {
			return 0
		}

		return Query.driver.count(table: table, filters: self.filters)
	}

	//continues
	public func filter(key: String, _ value: String) -> Query {
		let filter = CompareFilter(key: key, value: value, comparison: .Equals)
		self.filters.append(filter)

		return self
	}

	public func filter(key: String, _ comparison: CompareFilter.Comparison, _ value: String) -> Query {
		let filter = CompareFilter(key: key, value: value, comparison: comparison)
		self.filters.append(filter)

		return self
	}

	public func filter(key: String, in superSet: [String]) -> Query {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .In)
		self.filters.append(filter)

		return self
	}

	public func filter(key: String, notIn superSet: [String]) -> Query {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .NotIn)
		self.filters.append(filter)

		return self
	}

	public func table(table: String) -> Query {
		self.table = table
		return self
	}

	public init() {

	}

	public var table: String?
}
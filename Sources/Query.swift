public class Query<T: Model> {

	public var filters: [Filter] = []

	//ends
	//var first: Model?
	public var first: T? {
		if let serialized = Database.driver.fetchOne(table: self.table, filters: self.filters) {
			return T(serialized: serialized)
		} else {
			return nil
		}
	}

	//var results: [Model]
	public var results: [T] {
		var models: [T] = []

		let serializeds = Database.driver.fetch(table: self.table, filters: self.filters)
		for serialized in serializeds {
			let model = T(serialized: serialized)
			models.append(model)
		}

		return models
	}

	public func update(data: [String: String]) {
		Database.driver.update(table: self.table, filters: self.filters, items: data)
	}

	public func insert(data: [String: String]) {
		Database.driver.insert(table: self.table, items: [data])
	}

	public func upsert(data: [[String: String]]) {
		Database.driver.upsert(table: self.table, items: data)
	}

	public func upsert(data: [String: String]) {
		Database.driver.upsert(table: self.table, items: [data])
	}

	public func insert(data: [[String: String]]) {
		Database.driver.insert(table: self.table, items: data)
	}

	public func delete() {
		Database.driver.delete(table: self.table, filters: self.filters)
	}

	public var exists: Bool{
		return Database.driver.exists(table: self.table, filters: self.filters)
	}

	public var count: Int {
		return Database.driver.count(table: self.table, filters: self.filters)
	}

	//model
	public func find(id: Int) -> T? {
		return self.filter("id", "\(id)").first
	}


	/* Internal Casts */
	///Inserts or updates the entity in the database.
	func save(model: T) {
		let data = model.serialize()

		if let id = model.id {
			self.filter("id", id).update(data)
		} else {
			self.insert(data)
		}
	}

	///Deletes the entity from the database.
	func delete(model: T) {
		guard let id = model.id else {
			return
		}

		self.filter("id", id).delete()
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

	public init() {
		self.table = T.table
	}

	public let table: String
}
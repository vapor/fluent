/**
	Base model for all Fluent entities. 

	Override the `table()`, `serialize()`, and `init(serialized:)`
	methods on your subclass. 
*/
class Model {
	///The entities database identifier. `nil` when not saved yet.
	var id: String?

	///The database table in which entities are stored.
	class func table() -> String {
		return ""
	}

	/**
		This method will be called when the entity is saved. 
		The keys of the dictionary are the column names
		in the database.
	*/
	func serialize() -> [String: String] {
		return [:]
	}

	func table() -> String {
		return self.dynamicType.table()
	}

	///Inserts or updates the entity in the database.
	func save() {
		let table = self.table()
		let data = self.serialize()

		print("Saving user with id '\(self.id)' to table '\(table)' with data \(data)")

		let query = Query(table: table, operation: .Save)
		query.id = self.id
		query.data = data

		Manager.query(query)
	}

	///Deletes the entity from the database.
	func delete() {
		guard let id = self.id else {
			print("No id on object")
			return
		}
		let table = self.table()

		print("Delete entity on '\(table)' with ID '\(id)'")

		let query = Query(table: table, operation: .Delete)
		query.id = id
		Manager.query(query)
	}

	/**
		
	*/
	class func find(id: Int) -> Model? {
		return self.find("\(id)")
	}

	class func find(id: String) -> Model? {
		let table = self.table()
		print("Finding entity on '\(table)' with ID '\(id)'")

		let query = Query(table: table, operation: .Get)
		query.id = id

		if let data = Manager.query(query) as? [String: String] {
			let model = self.init(serialized: data)
			model.id = id
			return model
		} else {
			return nil
		}
	}

	class func all() -> [Model] {
		let table = self.table()
		print("Finding all entities on '\(table)'")

		let query = Query(table: table, operation: .Get)

		if let data = Manager.query(query) as? [String: [String: String]] {
			var all: [Model] = []

			for (id, entity) in data {
				let model = self.init(serialized: entity)
				model.id = id
				all.append(model)
			}

			return all
		} else {
			return []
		}
	}

	///Called when an entity is selected from the database.
	required init(serialized: [String: String]) {
		self.id = serialized["id"]

	}
}

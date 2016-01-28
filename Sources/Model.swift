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

	class var query: Query {
		let table = self.table()
		return Query().table(table)
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

		let query = Query().table(table)
		if let id = self.id {
			query.filter("id", id).update(data)
		} else {
			query.insert(data)
		}
	}

	///Deletes the entity from the database.
	func delete() {
		guard let id = self.id else {
			return
		}

		let table = self.table()

		Query().table(table).filter("id", id).delete()
	}

	/**
		
	*/
	class func find(id: Int) -> Model? {
		return self.find("\(id)")
	}

	class func find(id: String) -> Model? {
		let table = self.table()

		if let data = Query().table(table).filter("id", id).first {
			let model = self.init(serialized: data)
			model.id = id
			return model
		} else {
			return nil
		}
	}

	class func all() -> [Model] {
		let table = self.table()

		var all: [Model] = []

		for entity in Query().table(table).results {
			let model = self.init(serialized: entity)
			all.append(model)
		}

		return all
	}

	init() {

	}

	///Called when an entity is selected from the database.
	required init(serialized: [String: String]) {
		self.id = serialized["id"]
	}
}

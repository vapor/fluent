/**
	Base model for all Fluent entities. 

	Override the `table()`, `serialize()`, and `init(serialized:)`
	methods on your subclass. 
*/
public class Model {
	///The entities database identifier. `nil` when not saved yet.
	public var id: String?

	///The database table in which entities are stored.
	public class func table() -> String {
		return ""
	}

	public class var query: Query {
		let table = self.table()

		let query = Query().table(table)

		query.map = { serialized in 
			return self.init(serialized: serialized)
		}

		return query
	}

	/**
		This method will be called when the entity is saved. 
		The keys of the dictionary are the column names
		in the database.
	*/
	public func serialize() -> [String: String] {
		return [:]
	}

	public func table() -> String {
		return self.dynamicType.table()
	}

	///Inserts or updates the entity in the database.
	public func save() {
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
	public func delete() {
		guard let id = self.id else {
			return
		}

		let table = self.table()

		Query().table(table).filter("id", id).delete()
	}

	/**
		
	*/
	public class func find(id: Int) -> Model? {
		return self.find("\(id)")
	}

	public class func find(id: String) -> Model? {
		let table = self.table()

		if let data = Query().table(table).filter("id", id).first {
			let model = self.init(serialized: data)
			model.id = id
			return model
		} else {
			return nil
		}
	}

	public static var all: [Model] {
		let table = self.table()

		var all: [Model] = []

		for entity in Query().table(table).results {
			let model = self.init(serialized: entity)
			all.append(model)
		}

		return all
	}

	public init() {

	}

	///Called when an entity is selected from the database.
	public required init(serialized: [String: String]) {
		self.id = serialized["id"]
	}
}

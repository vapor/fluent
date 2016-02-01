/**
	Base model for all Fluent entities. 

	Override the `table()`, `serialize()`, and `init(serialized:)`
	methods on your subclass. 
*/
public protocol Model {
	///The entities database identifier. `nil` when not saved yet.
	var id: String? { get }

	///The database table in which entities are stored.
	static var table: String { get }

	/**
		This method will be called when the entity is saved. 
		The keys of the dictionary are the column names
		in the database.
	*/
	func serialize() -> [String: String]

	init(serialized: [String: String])
}

extension Model {

	public func save() {
		Query().save(self)
	}

	public func delete() {
		Query().delete(self)
	}

	public static func find(id: Int) -> Self? {
		return Query().find(id)
	}

}
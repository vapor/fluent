class MemoryDriver: Driver {
	var memory: [
		String: [ //table
			String: //id
				[ //entity
					String: String
				]
		]
	] = [ "users":
			[ "1": 
				[
					"first_name": "Tanner",
					"last_name": "Nelson",
					"email": "me@tanner.xyz"
				]
			]
		]

	func query(query: Query) -> Any? {
		print("Query")

		switch query.operation {
		case .Get:
			print("Get")
			if let id = query.id {
				print("id = \(id)")
				if let data = self.memory[query.table]?[id] {
					return data
				}
			} else {
				print("all")
				return self.memory[query.table]
			}
		case .Save:
			print("Save")
			if let data = query.data {
				if let id = query.id {
					print("id = \(id)")
					self.memory[query.table]?[id] = data
				} else {
					self.memory[query.table]?["5"] = data
				}
			}
		case .Delete:
			print("Delete")
			if let id = query.id {
				print("id = \(id)")
				self.memory[query.table]?.removeValueForKey(id)
			}
		}

		return nil
	}

}
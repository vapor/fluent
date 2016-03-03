import LoggerAPI

public class SQL {

	public var table: String
	public var operation: Operation

	public var filters: [Filter]?
	public var limit: Int?
	public var data: [String: String]?

	public static var quote: String = "`"

	public enum Operation {
		case SELECT, DELETE, INSERT, UPDATE
	}

	public init(operation: Operation, table: String) {
		self.operation = operation
		self.table = table
	}

	public func quoteWord(word: String) -> String {
		return SQL.quote+word+SQL.quote
	}

	public func getData(key: String) -> String {
		if let data = self.data {
			if let val = data[key] {
				if val == "NULL" {
					return val
				} else {
					return "'\(val)'"
				}
			}
		}
		return ""
	}

	public var query: String {
		var query: [String] = []

		switch self.operation {
		case .SELECT:
			query.append("SELECT * FROM")
		case .DELETE:
			query.append("DELETE FROM")
		case .INSERT:
			query.append("INSERT INTO")
		case .UPDATE:
			query.append("UPDATE")
		}
		//UPDATE table_name
// SET column1 = value1, column2 = value2...., columnN = valueN
// WHERE [condition];

		query.append(self.quoteWord(self.table))

		if let data = self.data {

			if self.operation == .INSERT {

				var columns: [String] = []
				var values: [String] = []

				for key in data.keys {
					columns.append(self.quoteWord(key))
					values.append(self.getData(key))
				}

				let columnsString = columns.joinWithSeparator(", ")
				let valuesString = values.joinWithSeparator(", ")
				query.append("(\(columnsString)) VALUES (\(valuesString))")

			} else if self.operation == .UPDATE {

				var updates: [String] = []

				for key in data.keys {
					let quotedKey = self.quoteWord(key)
					updates.append("\(quotedKey) = " + self.getData(key))
				}

				let updatesString = updates.joinWithSeparator(", ")
				query.append("SET \(updatesString)")

			}

		}

		if let filters = self.filters {
			if filters.count > 0 {
				query.append("WHERE")

				query = generateFilterQuery(0, query, filters)
			}
		}

		if let limit = self.limit {
			query.append("LIMIT \(limit)")
		}

		let queryString = query.joinWithSeparator(" ")

		self.log(queryString)

		return queryString + ";"
	}

	public func getFilterValue(filter: CompareFilter) -> String {
		return "'\(filter.value)'"
	}

	public func getFilterValue(filter: SubsetFilter) -> String {
		return "'" + filter.superSet.joinWithSeparator("','") + "'"
	}

	func generateFilterQuery(index: Int,_ query: [String] ,_ filters: [Filter]) -> [String] {
		var i = index
		var q = query
		for (_, filter) in filters.enumerate() {
			if let filter = filter as? CompareFilter {
				var operation: String = ""
				switch filter.comparison {
				case .Equals:
					operation = "="
				case .NotEquals:
					operation = "!="
				case .GreaterThanOrEquals:
					operation = ">="
				case .LessThanOrEquals:
					operation = "<="
				case .GreaterThan:
					operation = ">"
				case .LessThan:
					operation = "<"
				}

				let quotedKey = self.quoteWord(filter.key)

				var type: String = "AND"
				switch filter.groupType {
				case .And:
					type = "AND"
				case .Or:
					type = "OR"
				}
				q.append((i > 0) ? " \(type)" : "")
				q.append(" \(quotedKey) \(operation) ")
				q.append(self.getFilterValue(filter))
			}
			else if let filter = filter as? SubsetFilter {
				if(filter.superSet.count == 0) {
					continue
				}

				var operation: String = ""
				switch filter.comparison {
				case .In:
					operation = "IN"
				case .NotIn:
					operation = "NOT IN"
				}

				let quotedKey = self.quoteWord(filter.key)

				let holdersStr = self.getFilterValue(filter)

				var type: String = "AND"
				switch filter.groupType {
				case .And:
					type = "AND"
				case .Or:
					type = "OR"
				}

				q.append((i > 0) ? " \(type)" : "")
				q.append(" \(quotedKey) \(operation) (\(holdersStr))")

			}
			else if let filter = filter as? FilterGroup {
				if(filter.filters.count == 0) {
					continue
				}

				var type: String = "AND"
				switch filter.groupType {
					case .And:
						type = "AND"
					case .Or:
						type = "OR"
				}

				q.append((i > 0) ? " \(type)" : "")
				q.append("(")
				q = generateFilterQuery(0,q,filter.filters)
				q.append(")")
			}
			i = i+1
		}
		return q
	}

	func log(message: Any) {
		Log.debug("[SQL] \(message)")
	}
}
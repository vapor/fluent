class CompareFilter: Filter {
	enum Comparison {
		case Equal, NotEqual, GreaterThanOrEqual, LessThanOrEqual, GreaterThan, LessThan
	}

	let key: String
	let value: String
	let comparison: Comparison

	init(key: String, value: String, comparison: Comparison) {
		self.key = key
		self.value = value
		self.comparison = comparison
	}
}

class SubsetFilter: Filter {
	enum Comparison {
		case In, NotIn
	}

	let key: String
	let superSet: [String]
	let comparison: Comparison

	init(key: String, superSet: [String], comparison: Comparison) {
		self.key = key
		self.superSet = superSet
		self.comparison = comparison
	}
}

class Filter {

}
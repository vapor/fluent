public class CompareFilter: Filter {
	public enum Comparison {
		case Equals, NotEquals, GreaterThanOrEquals, LessThanOrEquals, GreaterThan, LessThan
	}

	public let key: String
	public let value: String
	public let comparison: Comparison

	init(key: String, value: String, comparison: Comparison) {
		self.key = key
		self.value = value
		self.comparison = comparison
	}
}

public class SubsetFilter: Filter {
	public enum Comparison {
		case In, NotIn
	}

	public let key: String
	public let superSet: [String]
	public let comparison: Comparison

	init(key: String, superSet: [String], comparison: Comparison) {
		self.key = key
		self.superSet = superSet
		self.comparison = comparison
	}
}

public class Filter {

}
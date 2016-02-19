public class CompareFilter: Filter {
	public enum Comparison: String {
		case Equals = "="
		case NotEquals = "!="
		case GreaterThanOrEquals = ">="
		case LessThanOrEquals = "<="
		case GreaterThan = ">"
		case LessThan = "<"
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
	public enum Comparison: String {
		case In = "IN"
		case NotIn = "NOT IN"
	}

	public let key: String
	public let superSet: [String]
	public let comparison: Comparison

	init(key: String, superSet: [String], comparison: Comparison) {
		self.key = key
		self.superSet = superSet
		self.comparison = comparison
	}

	var superSetString: String {
		let elements = superSet.map({ "'\($0)'" })
		return "(" + elements.joinWithSeparator(",") + ")"
	}
}

public class Filter {

}

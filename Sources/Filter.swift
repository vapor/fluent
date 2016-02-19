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
	public let joinOperator: Operator

	init(key: String, value: String, comparison: Comparison, joinOperator: Operator) {
		self.key = key
		self.value = value
		self.comparison = comparison
		self.joinOperator = joinOperator
	}

	override func joinOperation() -> Operator {
		return joinOperator
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
	public let joinOperator: Operator

	init(key: String, superSet: [String], comparison: Comparison, joinOperator: Operator) {
		self.key = key
		self.superSet = superSet
		self.comparison = comparison
		self.joinOperator = joinOperator
	}

	var superSetString: String {
		let elements = superSet.map({ "'\($0)'" })
		return "(" + elements.joinWithSeparator(",") + ")"
	}

	override func joinOperation() -> Operator {
		return joinOperator
	}
}

public class Filter {
	public enum Operator: String {
		case And = "AND"
		case Or = "OR"
		case None = ""
	}

	func joinOperation() -> Operator {
		return .None
	}
}

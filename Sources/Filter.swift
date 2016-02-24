public protocol FilterComparison {

}

public class Filter {
	public enum Equality: FilterComparison {
		case Equals, NotEquals, GreaterThanOrEquals, LessThanOrEquals, GreaterThan, LessThan
	}

	public enum Subset: FilterComparison {
		case In, NotIn
	}

	public enum Operand {
		case Value(String)
		case ValueSet([String])

		public var value: String {
			switch self {
				case .Value(let value):
					return value
				default:
					return ""
			}
		}

		public var valueSet: [String] {
			switch self {
				case .ValueSet(let valueSet):
					return valueSet
				default:
					return [String]()
			}
		}

		public var eitherValue: Any {
			switch self {
				case .Value(let value):
					return value
				case .ValueSet(let valueSet):
					return valueSet
			}
		}
	}

	let key: String
	let comparison: FilterComparison
	let operand: Operand

	init(key: String, comparison: FilterComparison, operand: Operand) {
		self.key = key
		self.comparison = comparison
		self.operand = operand
	}
}

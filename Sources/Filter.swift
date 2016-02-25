public protocol Filterable {}

extension String: Filterable {}

// We can't specify it to be an array of Strings as of now. Let's just hope that
// the init method of SubsetFilter will take care of this.
extension Array: Filterable {}

public protocol FilterComparison {}

public protocol Filter {
  var key: String { get }
  var value: Filterable { get }
  var comparison: FilterComparison { get }
}

public class EqualityFilter: Filter {
  public enum EqualityComparison: FilterComparison {
    case Equals, NotEquals, GreaterThanOrEquals, LessThanOrEquals, GreaterThan, LessThan
  }
  
  public let key: String
  public let value: Filterable
  public let comparison: FilterComparison

  init(key: String, comparison: EqualityComparison, value: String) {
    self.key = key
    self.value = value
    self.comparison = comparison
  }
}

public class SubsetFilter: Filter {
	public enum SubsetComparison: FilterComparison {
		case In, NotIn
	}

	public let key: String
	public let value: Filterable
	public let comparison: FilterComparison

	init(key: String, comparison: SubsetComparison, value: [String]) {
		self.key = key
		self.value = value
		self.comparison = comparison
	}
}

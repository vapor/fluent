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
		super.init(type: .And)
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
		super.init(type: .And)
	}
}

public class FilterGroup : Filter {

	public var filters: [Filter] = []

	public func filter(type: GroupType,_ key: String, _ comparison: CompareFilter.Comparison, _ value: String) -> FilterGroup {
		let filter = CompareFilter(key: key, value: value, comparison: comparison)
		filter.groupType = type
		self.filters.append(filter)

		return self
	}

	public func filter(type: GroupType,_ key: String, in superSet: [String]) -> FilterGroup {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .In)
		filter.groupType = type
		self.filters.append(filter)

		return self
	}

	public func filter(type: GroupType,_ key: String, notIn superSet: [String]) -> FilterGroup {
		let filter = SubsetFilter(key: key, superSet: superSet, comparison: .NotIn)
		filter.groupType = type
		self.filters.append(filter)

		return self
	}

	//continues
	public func filter(key: String, _ value: String) -> FilterGroup {
		return self.filter(.And, key, .Equals, value)
	}

	public func filter(key: String, _ comparison: CompareFilter.Comparison, _ value: String) -> FilterGroup {
		return self.filter(.And, key, comparison, value)
	}

	public func filter(key: String, in superSet: [String]) -> FilterGroup {
		return self.filter(.And, key, in: superSet)
	}

	public func filter(key: String, notIn superSet: [String]) -> FilterGroup {
		return self.filter(.And, key, notIn: superSet)
	}

	//continues
	public func and(key: String, _ value: String) -> FilterGroup {
		return self.filter(key,value)
	}

	public func or(key: String, _ value: String) -> FilterGroup {
		return self.filter(.Or, key, .Equals, value)
	}

	public func and(key: String, _ comparison: CompareFilter.Comparison, _ value: String) -> FilterGroup {
		return self.filter(key,comparison,value)
	}
	public func or(key: String, _ comparison: CompareFilter.Comparison, _ value: String) -> FilterGroup {
		return self.filter(.Or, key,comparison, value)
	}

	public func and(key: String, in superSet: [String]) -> FilterGroup {
		return self.filter(key, in:superSet)
	}
	public func or(key: String, in superSet: [String]) -> FilterGroup {
		return self.filter(.Or, key, in: superSet)
	}

	public func and(key: String, notIn superSet: [String]) -> FilterGroup {
		return self.filter(key, notIn: superSet)
	}
	public func or(key: String, notIn superSet: [String]) -> FilterGroup {
		return self.filter(.Or, key, notIn: superSet)
	}

	public func group (type: FilterGroup.GroupType,_ filters: (group: FilterGroup)->FilterGroup) -> FilterGroup {
		let filterGroup = FilterGroup(type:type)
		self.filters.append(filters(group: filterGroup))
		return self
	}

	public func group (filters: (group: FilterGroup)->FilterGroup) -> FilterGroup {
		return self.group(.And, filters)
	}
}

public class Filter {

	public enum GroupType {
		case And, Or
	}

	public var groupType: GroupType = .And
	public var isRaw: Bool = false

	init(type: GroupType) {
		self.groupType = type
	}

}

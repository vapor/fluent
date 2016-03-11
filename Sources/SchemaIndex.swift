public class SchemaIndex: SchemaType {

	public enum `Type`: CustomStringConvertible {

		public enum Direction: CustomStringConvertible {
			case Ascending
			case Descending

			public var description: String {
				switch self {
					case .Ascending:
						return "asc"
					case .Descending:
						return "desc"
				}
			}
		}

		case Default(direction: Direction?)
		case Primary
		case Unique

		public var description: String {
			switch self {
				case .Default(let direction) where direction != nil:
					return "index_\(direction!)"
				case .Default:
					return "index"
				case .Primary:
					return "primary"
				case .Unique:
					return "unique"
			}
		}
	}

	public let type: Type
	public let columns: [SchemaColumn]

	public init(name: String? = nil, type: Type, columns: [SchemaColumn]) {
		let columns = Array(columns)
		let name = name ?? ("\(type)_" + (columns.map { $0.name }.joinWithSeparator("_")))

		self.type = type
		self.columns = columns

		super.init(name: name)
	}

}

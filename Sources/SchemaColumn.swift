public class SchemaColumn: SchemaType {

	public enum `Type` {
		case String(length: Int)
		case Text(length: Int)
		case Integer(length: Int)
		case Double(length: Int)
		case Blob(length: Int)
	}

	public var nullable: Bool? = nil
	public var indexes: [SchemaIndex]? = nil
	public var type: Type? = nil

}

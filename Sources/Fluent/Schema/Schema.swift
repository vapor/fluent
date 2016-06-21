/**
    Represents an action on the
    Schema of a collection.
*/
public enum Schema {
    case create(entity: String, create: [Field])
    case modify(entity: String, create: [Field], delete: [String])
    case delete(entity: String)
}

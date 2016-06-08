/**
    A type of data that can be retrieved
    or stored in a database.
*/
public protocol Value: CustomStringConvertible, Polymorphic {
    var structuredData: StructuredData { get }
}

extension Int: Value {
    public var structuredData: StructuredData {
        return .int(self)
    }
}

extension String: Value {
    public var structuredData: StructuredData {
        return .string(self)
    }

    public var description: String {
        return self
    }
}

extension Double: Value {
    public var structuredData: StructuredData {
        return .double(self)
    }
}

extension Float: Value {
    public var structuredData: StructuredData {
        return .double(Double(self))
    }
}

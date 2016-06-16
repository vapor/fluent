/**
    A type of data that can be retrieved
    or stored in a database.
*/
public protocol Value: CustomStringConvertible, StructuredDataRepresentable, Polymorphic {}

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

extension StructuredData: Fluent.Value {
    public var structuredData: StructuredData {
        return self
    }
}

extension Bool: Value {
    public var structuredData: StructuredData {
        return .bool(self)
    }
}

extension StructuredData: CustomStringConvertible {
    public var description: String {
        switch self {
        case .array(let array):
            return array.description
        case .bool(let bool):
            return bool.description
        case .data(let data):
            return data.description
        case .dictionary(let dict):
            return dict.description
        case .double(let double):
            return double.description
        case .int(let int):
            return int.description
        case .null:
            return "NULL"
        case .string(let string):
            return string
        }
    }
}

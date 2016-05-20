/**
    A type of data that can be retrieved
    or stored in a database.
*/
public protocol Value: CustomStringConvertible, Polymorphic {
    var structuredData: StructuredData { get }
}

public protocol Polymorphic {
    var int: Int? { get }
    var string: String? { get }
    var double: Double? { get }
}

public enum StructuredData {
    case null
    case bool(Bool)
    case integer(Int)
    case double(Double)
    case string(String)
    case array([StructuredData])
    case dictionary([String: StructuredData])
}

extension Value {
    public var string: String? {
        switch structuredData {
        case .bool(let bool):
            return "\(bool)"
        case .integer(let int):
            return "\(int)"
        case .double(let double):
            return "\(double)"
        case .string(let string):
            return "\(string)"
        default:
            return nil
        }
    }

    public var int: Int? {
        switch structuredData {
        case .integer(let int):
            return int
        case .string(let string):
            return Int(string)
        case .double(let double):
            return Int(double)
        case .bool(let bool):
            return bool ? 1 : 0
        default:
            return nil
        }
    }

    public var double: Double? {
        switch structuredData {
        case .double(let double):
            return double
        case .string(let string):
            return Double(string)
        case .integer(let int):
            return Double(int)
        case .bool(let bool):
            return bool ? 1.0 : 0.0
        default:
            return nil
        }
    }
}

extension Value {
    public var description: String {
        return self.string ?? ""
    }
}

extension Int: Value {
    public var structuredData: StructuredData {
        return .integer(self)
    }
}

extension Double: Value {
    public var structuredData: StructuredData {
        return .double(self)
    }
}

extension String: Value {
    public var structuredData: StructuredData {
        return .string(self)
    }
}

extension Bool: Value {
    public var structuredData: StructuredData {
        return .bool(self)
    }
}

extension StructuredData: Value {
    public var structuredData: StructuredData {
        return self
    }
}

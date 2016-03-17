public protocol Value: CustomStringConvertible {
    var string: String { get }
}

extension Value {
    var int: Int? {
        return Int(self.string)
    }
    
    var float: Float? {
        return Float(self.string)
    }
    
    var double: Double? {
        return Double(self.string)
    }
}

extension Value {
    public var description: String {
        return self.string
    }
}

extension Int: Value {
    public var string: String {
        return "\(self)"
    }
}

extension Int64: Value {
    public var string: String {
        return "\(self)"
    }
}

extension Int32: Value {
    public var string: String {
        return "\(self)"
    }
}

extension Int16: Value {
    public var string: String {
        return "\(self)"
    }
}

extension Int8: Value {
    public var string: String {
        return "\(self)"
    }
}

extension UInt: Value {
    public var string: String {
        return "\(self)"
    }
}

extension UInt64: Value {
    public var string: String {
        return "\(self)"
    }
}

extension UInt32: Value {
    public var string: String {
        return "\(self)"
    }
}

extension UInt16: Value {
    public var string: String {
        return "\(self)"
    }
}

extension UInt8: Value {
    public var string: String {
        return "\(self)"
    }
}


extension Float: Value {
    public var string: String {
        return "\(self)"
    }
}

extension Double: Value {
    public var string: String {
        return "\(self)"
    }
}

extension String: Value {
    public var string: String {
        return self
    }
}

extension Bool: Value {
    public var string: String {
        return self ? "true" : "false"
    }
}

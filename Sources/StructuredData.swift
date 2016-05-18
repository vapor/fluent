import Foundation

public enum StructuredData {
    case null
    case bool(Bool)
    case integer(Int)
    case double(Double)
    case string(String)
    case array([StructuredData])
    case dictionary([String: StructuredData])
}

//Mark: Conform to all LiteralConvertibles

extension StructuredData: ArrayLiteralConvertible {
    public init(arrayLiteral elements: StructuredData...) {
        self = .array(elements)
    }
}

extension StructuredData: BooleanLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension StructuredData: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, StructuredData)...) {
        var dict = [String: StructuredData]()
        
        for element in elements {
            dict[element.0] = element.1
        }
        
        self = .dictionary(dict)
    }
}

extension StructuredData: FloatLiteralConvertible {
    public init(floatLiteral value: Float) {
        self = .double(Double(value))
    }
}

extension StructuredData: NilLiteralConvertible {
    public init(nilLiteral: Void) {
        self = .null
    }
}

extension StructuredData: IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self = .integer(value)
    }
}

extension StructuredData: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
}

extension StructuredData: StringInterpolationConvertible {
    public init(stringInterpolation strings: StructuredData...) {
        var string = ""
        
        for element in strings {
            if case .string(let segment) = element {
                string += segment
            }
        }
        
        self = .string(string)
    }
    
    public init<T>(stringInterpolationSegment expr: T) {
        self = .string(String(T))
    }
}

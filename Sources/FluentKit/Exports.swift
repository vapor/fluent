@_exported import NIO


public struct EncoderWrapper: Encodable {
    public let encodable: Encodable
    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    public func encode(to encoder: Encoder) throws {
        try self.encodable.encode(to: encoder)
    }
}

public struct StringCodingKey: CodingKey {
    public var stringValue: String
    
    public init(_ string: String) {
        self.stringValue = string
    }
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public var intValue: Int? {
        return Int(self.stringValue)
    }
    
    public init?(intValue: Int) {
        self.stringValue = intValue.description
    }
}


public struct DecoderUnwrapper: Decodable {
    public let decoder: Decoder
    public init(from decoder: Decoder) {
        self.decoder = decoder
    }
}


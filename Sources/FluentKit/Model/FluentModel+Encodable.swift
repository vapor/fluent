extension FluentModel where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FluentCodingKey.self)
        for field in self.properties {
            try field.encode(to: &container)
        }
    }
}

extension FluentModel where Self: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FluentCodingKey.self)
        self.init(storage: .empty)
        for field in self.properties {
            if field.name == self.id.name {
                try? field.decode(from: container)
            } else {
                try field.decode(from: container)
            }
        }
    }
}

public struct FluentCodingKey: CodingKey {
    let string: String
    init(_ string: String) {
        self.string = string
    }
    
    public var stringValue: String {
        return self.string
    }
    
    public init?(stringValue: String) {
        self.init(stringValue)
    }
    
    public var intValue: Int? {
        return Int(self.string)
    }
    
    public init?(intValue: Int) {
        self.init(intValue.description)
    }
}

extension FluentModel where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FluentFieldKey.self)
        for field in self.fields {
            try field.encode(to: &container)
        }
    }
}

extension FluentModel where Self: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FluentFieldKey.self)
        self.init(storage: .empty)
        for field in self.fields {
            if field.name == self.id.name {
                try? field.decode(from: container)
            } else {
                try field.decode(from: container)
            }
        }
    }
}

public struct FluentFieldKey: CodingKey {
    let field: AnyFluentField
    init(field: AnyFluentField) {
        self.field = field
    }
    
    public var stringValue: String {
        return self.field.name
    }
    
    public init?(stringValue: String) {
        fatalError()
    }
    
    public var intValue: Int? {
        return nil
    }
    
    public init?(intValue: Int) {
        fatalError()
    }
}

extension FluentModel where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FluentFieldKey.self)
        for field in self.fields {
            try field.encode(to: &container)
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

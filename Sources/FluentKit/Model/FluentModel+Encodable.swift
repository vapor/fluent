extension FluentEntity where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        for field in self.properties {
            try field.encode(to: &container)
        }
    }
}

extension FluentEntity where Self: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)
        self.init()
        for field in self.properties {
            do {
                try field.decode(from: container)
            } catch {
                print("Could not decode \(field.name): \(error)")
            }
        }
    }
}

//public struct FluentCodingKey: CodingKey {
//    let string: String
//    init(_ string: String) {
//        self.string = string
//    }
//
//    public var stringValue: String {
//        return self.string
//    }
//
//    public init?(stringValue: String) {
//        self.init(stringValue)
//    }
//
//    public var intValue: Int? {
//        return Int(self.string)
//    }
//
//    public init?(intValue: Int) {
//        self.init(intValue.description)
//    }
//}

import Foundation

public struct PageLimit: Codable, ExpressibleByIntegerLiteral {
    public let value: Int?
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.value = value
    }

    private init(value: Int?) {
        self.value = value
    }

    public static var noLimit: PageLimit {
        .init(value: nil)
    }
}

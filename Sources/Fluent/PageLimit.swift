import Foundation

public struct PageLimit: Sendable {
    public let value: Int?
    
    public static var noLimit: PageLimit {
        .init(value: nil)
    }
}

extension PageLimit {
    public init(_ value: Int) {
        self.value = value
    }
}

extension PageLimit: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.value = value
    }
}

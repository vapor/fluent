public protocol QueryData {
    static func fluentEncodable(_ encodable: Encodable) -> Self
}

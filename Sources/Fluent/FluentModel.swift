public protocol FluentModel: Codable {
    static var entity: String { get }
}

extension FluentModel {
    public static var entity: String {
        return "\(Self.self)"
    }
}

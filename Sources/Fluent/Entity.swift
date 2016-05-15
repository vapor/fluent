
public protocol Entity: Unboxable {
    static var entity: String { get }
    var id: String? { get }
}

extension Entity {
    public static var entity: String {
        return String(self)
    }
}

public protocol Entity {
    static var entity: String { get }
    var id: String? { get }
    
    func serialize() -> [String: Value?]
    init(serialized: [String: Value])
}

extension Entity {
    public static var entity: String {
        return String(self)
    }
}
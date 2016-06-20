public protocol Preparation {
    static func prepare(database: Database) throws
    static func revert(database: Database) throws
}

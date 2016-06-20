/**
    A SQL serializer.
*/
public protocol SQLSerializer {
    init(sql: SQL)
    func serialize() -> (String, [Value])
}

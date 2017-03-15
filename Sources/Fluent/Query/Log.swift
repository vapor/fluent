import Foundation

public struct Log {
    /// The time the query was logged
    public var time: Date

    /// Output of the log
    public var log: String

    /// Create a log from a raw log string.
    init(raw: String) {
        time = Date()
        log = raw
    }

    /// Create a log from raw sql and values.
    init(sql: String, values: [Node] = []) {
        var log = sql
        if values.count > 0 {
            let valuesString = values.map({ $0.string ?? "" }).joined(separator: ", ")
            log += " [\(valuesString)]"
        }

        self.init(raw: log)
    }

    /// Create a log from a Query
    init<E: Entity>(_ query: Query<E>) {
        let serializer = GeneralSQLSerializer(query)
        let (sql, values) = serializer.serialize()
        self.init(sql: sql, values: values)
    }
}

extension Log: CustomStringConvertible {
    public var description: String {
        return "[\(time)] \(log)"
    }
}

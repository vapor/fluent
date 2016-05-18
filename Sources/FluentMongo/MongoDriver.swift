import Fluent
import MongoKitten

public class MongoDriver: Fluent.Driver {
    var database: MongoKitten.Database
    public var idKey: String = "_id"

    public enum Error: ErrorProtocol {
        case unsupported(String)
    }
    
    public init(database: String, user: String, password: String, port: Int) throws {
        let server = try Server("mongodb://\(user):\(password)@localhost:\(port)", automatically: true)
        self.database = server[database]
    }

    
    public func execute<T: Model>(_ query: Fluent.Query<T>) throws -> [[String: Fluent.Value]] {
        var items: [[String: Fluent.Value]] = []

        print("Mongo executing: \(query)")

        switch query.action {
        case .select:
            let cursor = try select(query)
            for document in cursor {
                let item = convert(document: document)
                items.append(item)
            }
        case .insert:
            let document = try insert(query)
            if let document = document {
                let item = convert(document: document)
                items.append(item)
            }
        case .delete:
            try delete(query)
        default:
            throw Error.unsupported("Action \(query.action) is not yet supported.")
        }

        return items
    }

    private func convert(document: Document) -> [String: Fluent.Value] {
        var item: [String: Fluent.Value] = [:]

        document.forEach { key, val in
            item[key] = val.structuredData
        }

        return item
    }

    private func delete<T: Model>(_ query: Fluent.Query<T>) throws {
        if let q = query.mongoKittenQuery {
            try database[query.entity].remove(matching: q)
        } else {
            try database[query.entity].drop()
        }
    }

    private func insert<T: Model>(_ query: Fluent.Query<T>) throws -> Document? {
        guard let data = query.data else {
            return nil
        }

        var document: Document = [:]

        for (key, val) in data {
            document[key] = val?.bson ?? .null
        }
        
        return try database[query.entity].insert(document)
    }

    private func select<T: Model>(_ query: Fluent.Query<T>) throws -> Cursor<Document> {
        let cursor: Cursor<Document>

        if let q = query.mongoKittenQuery {
            cursor = try database[query.entity].find(matching: q)
        } else {
            cursor = try database[query.entity].find()
        }

        return cursor
    }
}

extension Fluent.Filter {
    var mongoKittenFilter: AQTQuery {
        let query: AQTQuery

        switch self {
        case .compare(let key, let comparison, let val):
            switch comparison {
            case .equals:
                query = AQTQuery(aqt: .valEquals(key: key, val: val.bson))
            case .greaterThan:
                query = AQTQuery(aqt: .greaterThan(key: key, val: val.bson))
            case .lessThan:
                query = AQTQuery(aqt: .smallerThan(key: key, val: val.bson))
            case .notEquals:
                query = AQTQuery(aqt: .valNotEquals(key: key, val: val.bson))
            }
        case .subset(let key, let scope, let values):
            switch scope {
            case .in:
                var ors: [AQT] = []

                for val in values {
                    ors.append(.valEquals(key: key, val: val.bson))
                }

                query = AQTQuery(aqt: .or(ors))
            case .notIn:
                var ands: [AQT] = []

                for val in values {
                    ands.append(.valNotEquals(key: key, val: val.bson))
                }

                query = AQTQuery(aqt: .and(ands))
            }
        }

        return query
    }
}

extension Fluent.Query {
    var mongoKittenQuery: AQTQuery? {
        guard filters.count != 0 else {
            return nil
        }

        var query: AQTQuery?

        for filter in filters {
            let subquery = filter.mongoKittenFilter

            if let q = query {
                query = subquery && q
            } else {
                query = subquery
            }
        }

        return query
    }
}

extension BSON.Value {
    var structuredData: StructuredData {
        switch self {
        case .double(let double):
            return .double(double)
        case .int64(let int):
            return .integer(Int(int))
        case .string(let string):
            return .string(string)
        case .objectId(let objId):
            return .string(objId.hexString)
        case .null:
            return .null
        default:
            print("Unsupported type BSON.Value -> SD: \(self)")
            return .null
        }
    }
}

extension Fluent.Value {
    var bson: BSON.Value {
        return structuredData.bson
    }
}

extension StructuredData {
    var bson: BSON.Value {
        switch self {
        case .integer(let int):
            return .int64(Int64(int))
        case .array(let array):
            let bsonArray = array.map { item in
                return item.bson
            }
            let document = Document(array: bsonArray)
            return .array(document)
        case .bool(let bool):
            return .boolean(bool)
        case .dictionary(let dict):
            var bsonDict: Document = [:]
            dict.forEach { key, val in
                bsonDict[key] = val.bson
            }
            return .document(bsonDict)
        case .double(let double):
            return .double(double)
        case .null:
            return .null
        case .string(let string):
            return .string(string)
        }
    }
}

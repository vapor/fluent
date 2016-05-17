import Fluent
import MongoKitten

public class MongoDriver: Fluent.Driver {
    var database: MongoKitten.Database
    public var idKey: String = "_id"

    public enum Error: ErrorProtocol {
        case unsupported(String)
    }
    
    public init(name: String) throws {
        print("MONGO INIT")

        let server = try Server("mongodb://test:test@localhost:27017", automatically: true)
        database = server[name]
    }

    
    public func execute<T: Model>(_ query: Fluent.Query<T>) throws -> [[String: Fluent.Value]] {
        print("MONGO EXECUTE")

        var items: [[String: Fluent.Value]] = []

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
                print(item)
                items.append(item)
            }
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

        if query.filters.count > 0 {
            var q: MongoKitten.Query?

            for filter in query.filters {
                switch filter {
                case .Compare(let key, _, let val):
                    if let key = key.string {
                        q = key == val.bson
                    }
                default:
                    break
                }
            }

            if let q = q {
                cursor = try database[query.entity].find(matching: q)
            } else {
                cursor = try database[query.entity].find()
            }
        } else {
            cursor = try database[query.entity].find()
        }

        return cursor
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

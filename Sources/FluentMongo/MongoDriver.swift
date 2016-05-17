import Fluent
import MongoKitten

public class MongoDriver: Fluent.Driver {
    var database: MongoKitten.Database
    
    public init(name: String) throws {
        print("MONGO INIT")

        let server = try Server("mongodb://test:test@localhost:27017", automatically: true)
        database = server[name]
    }
    
    public func execute<T: Model>(_ query: Fluent.Query<T>) throws -> [[String: Fluent.Value]] {
        let collection: Cursor<Document>

        if query.filters.count > 0 {
            var q: MongoKitten.Query?

            for filter in query.filters {
                switch filter {
                case .Compare(let key, let comparison, let val):
                    if
                        let key = key.string,
                        let val = val.string
                    {
                        q = key == val
                    }
                default:
                    break
                }
            }

            if let q = q {
                collection = try database[query.entity].find(matching: q)
            } else {
                collection = try database[query.entity].find()
            }
        } else {
            collection = try database[query.entity].find()
        }

        var items: [[String: Fluent.Value]] = []

        for document in collection {
            var item: [String: Fluent.Value] = [:]

            for (key, val) in document {
                switch val {
                case .double(let double):
                    item[key] = double
                case .int64(let int):
                    item[key] = Int(int)
                case .int32(let int):
                    item[key] = Int(int)
                case .string(let string):
                    item[key] = string
                default:
                    item[key] = "unsupported"
                }
            }

            items.append(item)
        }

        print("MONGO EXECUTE")
        return items
    }
}

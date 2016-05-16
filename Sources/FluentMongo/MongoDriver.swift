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
            collection = try database[query.entity].find()
        } else {
            collection = try database[query.entity].find()
        }

        var items: [[String: Fluent.Value]] = []

        for document in collection {
            var item: [String: Fluent.Value] = [:]

            for (key, val) in document {
                item[key] = "\(val)"
            }

            items.append(item)
        }

        print("MONGO EXECUTE")
        return items
    }
}

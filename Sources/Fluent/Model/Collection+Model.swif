import Async

extension Collection where Element: Model, Element.Database: QuerySupporting {
    public func save(on conn: DatabaseConnectable) -> Future<[Element]> {
        return self.map { $0.save(on: conn) }.flatten(on: conn)
    }
}

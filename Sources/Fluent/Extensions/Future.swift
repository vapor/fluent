import Async

extension Future where T: Model, T.Database: QuerySupporting {
    public func save(on connectable: DatabaseConnectable) -> Future<T> {
        return self.flatMap(to: T.self) { (model) in
            return model.save(on: connectable).transform(to: model)
        }
    }

    public func delete(on connectable: DatabaseConnectable) -> Future<T> {
        return self.flatMap(to: T.self) { (model) in
            return model.delete(on: connectable).transform(to: model)
        }
    }
}

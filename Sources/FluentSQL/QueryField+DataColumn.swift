/*
extension Query.Field {
    public func convertToDataColumn() throws -> DataColumn {
        switch self {
        case .field(let keyPath): return try keyPath.convertToDataColumn()
        case .reflected(let property, let entity): return .init(table: entity, name: property.path.first ?? "")
        }
    }
}

extension Query.FieldKeyPath {
    public func convertToDataColumn() throws -> DataColumn {
        guard let reflectable = rootType as? (AnyReflectable & AnyModel).Type else {
            throw FluentError(identifier: "reflectable", reason: "`\(rootType)` is not `Reflectable`.", source: .capture())
        }
        guard let property = try reflectable.anyReflectProperty(valueType: valueType, keyPath: keyPath) else {
            throw FluentError(identifier: "reflectableProperty", reason: "Could not reflect property `\(keyPath)`.", source: .capture())
        }
        return .init(table: reflectable.entity, name: property.path.first ?? "")
    }
}
*/

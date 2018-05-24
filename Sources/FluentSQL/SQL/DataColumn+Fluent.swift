extension DataColumn: PropertySupporting {
    public static func fluentProperty(_ property: QueryProperty) -> DataColumn {
        guard let model = property.rootType as? AnyModel.Type else {
            fatalError("`\(property.rootType)` does not conform to `Model`.")
        }
        return .init(table: model.entity, name: property.path.first ?? "")
    }
}

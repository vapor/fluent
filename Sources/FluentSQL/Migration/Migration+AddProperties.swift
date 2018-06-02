extension Migration where Self: Model, Database: SQLSupporting {
    /// See `Migration`.
    public static func prepare(on connection: Database.Connection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
        }
    }

    /// See `Migration`.
    public static func revert(on connection: Database.Connection) -> Future<Void> {
        return Database.delete(self, on: connection)
    }
}

/// MARK: Auto Migration

extension Model where Database: SQLSupporting {
    /// Automatically adds `SchemaField`s for each of this `Model`s properties.
    ///
    ///     PostgreSQLDatabase.create(User.self, on: conn) { builder in
    ///         try User.addProperties(to: builder)
    ///         // use the builder to add other things like indexes
    ///     }
    ///
    /// This method will be used automatically by `Model`'s default conformance to `Migration`.
    ///
    /// - parameters:
    ///     - builder: `SchemaCreator` to add the properties to.
    public static func addProperties(to builder: SchemaCreator<Self>) throws {
        guard let idProperty = try Self.reflectProperty(forKey: idKey) else {
            throw FluentError(identifier: "idProperty", reason: "Unable to reflect ID property for `\(Self.self)`.")
        }
        let properties = try Self.reflectProperties(depth: 0)
        for property in properties {
            builder.field(
                for: .fluentProperty(.reflected(property, rootType: self)),
                type: Database.schemaColumnType(for: property.type, primaryKey: idProperty.path == property.path)
            )
        }
    }
}

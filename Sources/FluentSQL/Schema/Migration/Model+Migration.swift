extension Migration where Self: Model, Database: SchemaSupporting {
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

extension Model where Database: SchemaSupporting {
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
            let field = Database.Schema.FieldDefinition.fluentFieldDefinition(
                .reflected(property, rootType: self),
                .fluentType(property.type),
                isIdentifier: property.path == idProperty.path
            )
            builder.schema.fluentCreateFields.append(field)
        }
    }
}

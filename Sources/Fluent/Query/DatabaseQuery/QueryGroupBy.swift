extension DatabaseQuery {
    /// Groups results together by a field. Combine with aggregate methods to get
    /// aggregate results for individual fields.
    public struct GroupBy {
        /// Internal storage type.
        enum Storage {
            case field(Database.QueryField)
        }

        /// Internal storage.
        let storage: Storage

        /// Returns the `QueryField` value.
        public func field() -> Database.QueryField? {
            switch storage {
            case .field(let field): return field
            }
        }

        /// Creates a new `GroupBy` object for a field.
        public static func field(_ field: Database.QueryField) -> GroupBy {
            return .init(storage: .field(field))
        }
    }
}

// MARK: Builder

extension QueryBuilder {
    /// Add a Group By to the Query.
    public func group<T>(by field: KeyPath<Model, T>) throws -> Self {
        return try addGroupBy(.field(Model.Database.queryField(for: field)))
    }
    
    /// Add a Group By to the Query.
    public func addGroupBy(_ groupBy: DatabaseQuery<Model.Database>.GroupBy) -> Self {
        query.groups.append(groupBy)
        return self
    }
}

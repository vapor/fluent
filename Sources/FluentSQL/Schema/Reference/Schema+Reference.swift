extension Schema where Database: ReferenceSupporting {
    /// A reference / foreign key is a field (or collection of fields) in one table
    /// that uniquely identifies a row of another table or the same table.
    public struct Reference {
        /// Actions that will take place when a reference is modified.
        public struct Actions {
            /// Action to take if referenced entities are updated.
            public var update: ActionType?

            /// Action to take if referenced entities are deleted.
            public var delete: ActionType?

            /// Creates a new `ReferentialActions`
            public init(update: ActionType? = nil, delete: ActionType? = nil) {
                self.update = update
                self.delete = delete
            }

            /// The default `ReferentialActions`
            public static var `default`: Actions { return  .init(update: nil, delete: nil) }

            /// The default `ReferentialActions`
            public static var prevent: Actions { return  .init(update: .prevent, delete: .prevent) }

            /// The default `ReferentialActions`
            public static var nullify: Actions { return  .init(update: .nullify, delete: .nullify) }

            /// The default `ReferentialActions`
            public static var update: Actions { return  .init(update: .update, delete: .update) }
        }

        /// Supported referential actions.
        public enum ActionType {
            /// Prevent changes to the database that will affect this reference.
            case prevent
            /// If this reference is changed, nullify the relation.
            /// Note: Requires optional field.
            case nullify
            /// If this reference is changed, update any dependents.
            case update

            /// The default `ReferentialAction`
            public static var `default`: ActionType { return .prevent }
        }

        /// The base field.
        public let base: Query<Database>.Field

        /// The field this base field references.
        /// - note: this is a `QueryField` because we have limited info.
        /// we assume it is the same type as the base field.
        public let referenced: Query<Database>.Field

        /// The action to take if this reference is modified.
        public let actions: Actions

        /// Creates a new SchemaReference
        public init(
            base: Query<Database>.Field,
            referenced: Query<Database>.Field,
            actions: Actions
        ) {
            self.base = base
            self.referenced = referenced
            self.actions = actions
        }

        /// Convenience init w/ schema field
        public init(base: FieldDefinition, referenced: Query<Database>.Field, actions: Actions) {
            self.base = base.field
            self.referenced = referenced
            self.actions = actions
        }
    }

    /// Field to field references for this database schema.
    public var addReferences: [Reference] {
        get { return extend.get(\Schema<Database>.addReferences, default: []) }
        set { extend.set(\Schema<Database>.addReferences, to: newValue) }
    }

    /// Field to field references for this database schema.
    public var removeReferences: [Reference] {
        get { return extend.get(\Schema<Database>.removeReferences, default: []) }
        set { extend.set(\Schema<Database>.removeReferences, to: newValue) }
    }
}

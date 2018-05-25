/// The children relation is one side of a one-to-many database relation.
///
/// The children relation will return all the
/// models that contain a reference to the parent's identifier.
///
/// The opposite side of this relation is called `Parent`.
public struct Children<Parent, Child>
    where Parent: Model, Child: Model, Parent.Database == Child.Database, Parent.Database: QuerySupporting
{
    /// Reference to the parent's ID
    public var parent: Parent

    enum ParentIDStorage {
        case optional(WritableKeyPath<Child, Parent.ID?>)
        case required(WritableKeyPath<Child, Parent.ID>)
    }

    /// Reference to the foreign key on t(he child.
    internal var parentID: ParentIDStorage

    /// Creates a new children relationship.
    fileprivate init(parent: Parent, parentID: ParentIDStorage) {
        self.parent = parent
        self.parentID = parentID
    }

    /// Create a query for all children.
    public func query(on conn: DatabaseConnectable) throws -> QueryBuilder<Child, Child> {
        let builder = Child.query(on: conn)
        switch parentID {
        case .optional(let parentID): try builder.filter(parentID == parent.requireID())
        case .required(let parentID): try builder.filter(parentID == parent.requireID())
        }
        return builder
    }
}

// MARK: Model

extension Model {
    /// Create a children relation for this model.
    ///
    /// The `foreignField` should refer to the field
    /// on the child entity that contains the parent's ID.
    public func children<Child>(_ parentID: WritableKeyPath<Child, Self.ID>) -> Children<Self, Child> {
        return Children(parent: self, parentID: .required(parentID))
    }

    /// Create a children relation for this model.
    ///
    /// The `foreignField` should refer to the field
    /// on the child entity that contains the parent's ID.
    public func children<Child>(_ parentID: WritableKeyPath<Child, Self.ID?>) -> Children<Self, Child> {
        return Children(parent: self, parentID: .optional(parentID))
    }
}

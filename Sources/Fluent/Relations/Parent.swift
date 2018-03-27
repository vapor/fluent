import Async

/// The parent relation is one side of a one-to-many database relation.
///
/// The parent relation will return the parent model that the supplied child references.
///
/// The opposite side of this relation is called `Children`.
public struct Parent<Child, Parent>
    where Child: Model, Parent: Model, Child.Database == Parent.Database
{
    /// The child object with reference to parent
    public var child: Child

    /// Reference to the parent's ID
    public var parentID: Parent.ID

    /// Creates a new children relationship.
    internal init(child: Child, parentID: Parent.ID) {
        self.child = child
        self.parentID = parentID
    }
}

extension Parent where Child.Database: QuerySupporting {
    /// Create a query for the parent.
    public func query(on conn: DatabaseConnectable) throws -> QueryBuilder<Parent, Parent> {
        return try Parent.query(on: conn)
            .filter(Parent.idKey, .equals, .data(Parent.Database.queryDataSerialize(data: parentID)))
    }

    /// Convenience for getting the parent.
    public func get(on conn: DatabaseConnectable) throws -> Future<Parent> {
        return try self.query(on: conn).first().map(to: Parent.self) { first in
            guard let parent = first else {
                throw FluentError(identifier: "parentRequired", reason: "This parent relationship could not be resolved", source: .capture())
            }
            return parent
        }
    }
}

// MARK: Model

extension Model {
    /// Create a children relation for this model.
    public func parent<P>(
        _ parentForeignIDKey: KeyPath<Self, P.ID>
    ) -> Parent<Self, P> where P: Model {
        return Parent(
            child: self,
            parentID: self[keyPath: parentForeignIDKey]
        )
    }

    /// Create a children relation for this model.
    public func parent<P>(
        _ parentForeignIDKey: KeyPath<Self, P.ID?>
    ) -> Parent<Self, P>? where P: Model {
        guard let parentID = self[keyPath: parentForeignIDKey] else {
            return nil
        }

        return Parent(
            child: self,
            parentID: parentID
        )
    }
}


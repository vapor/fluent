/// A siblings relation is a many-to-many relation between two models.
///
/// Each model should have an opposite Siblings relation.
///
///     typealias PetToyPivot = BasicPivot<Pet, Toy> // or custom `Pivot`
///
///     class Pet: Model {
///         var toys: Siblings<Pet, Toy, PetToyPivot> {
///             return siblings()
///         }
///     }
///
///     class Toy: Model {
///         var pets: Siblings<Toy, Pet, PetToyPivot> {
///             return siblings()
///         }
///     }
///
/// The third generic parameter to this relation is a Pivot.
/// Althrough not enforced by compiler (due to the handedness), the Through pivot _must_
/// have Left & Right model types equal to the siblings From & To models.
/// (This cannot be enforced by the compiler due to the handedness)
///
/// In other words a pivot for Foo & Bar should not be used in a siblings
/// relation between Boo & Baz.
///
/// It is recommended that you use your own types conforming to `Pivot`
/// for Siblings pivots as you cannot add additional fields to a `BasicPivot`.
public struct Siblings<Base, Related, Through>
    where
        Base: Model, Related: Model, Through: Pivot,
        Base.Database == Through.Database, Related.Database == Through.Database, Through.Database: JoinSupporting
{
    /// The base model which all fetched models should be related to.
    public let base: Base

    /// The base model's foreign id field that appears on the pivot.
    /// ex: Through.baseID
    internal let basePivotField: WritableKeyPath<Through, Base.ID>

    /// The related model's foreign id field that appears on the pivot.
    /// ex: Through.relatedID
    internal let relatedPivotField: WritableKeyPath<Through, Related.ID>

    /// Create a new Siblings relation.
    internal init(base: Base, related: Related.Type = Related.self, through: Through.Type = Through.self, basePivotField: WritableKeyPath<Through, Base.ID>, relatedPivotField: WritableKeyPath<Through, Related.ID>) {
        self.base = base
        self.basePivotField = basePivotField
        self.relatedPivotField = relatedPivotField
    }
}

extension Siblings where Base.Database: QuerySupporting {
    /// Creates a `QueryBuilder` for the `Related` model.
    public func query(on conn: DatabaseConnectable) throws -> QueryBuilder<Base.Database, Related> {
        return try Related.query(on: conn)
            .join(relatedPivotField, to: Related.idKey)
            .filter(basePivotField == base.requireID())
    }

    /// Create a query for the `Through` (pivot) model. This is useful for manually attaching / detaching pivots.
    ///
    ///     cat.toys.pivots(on: ...).filter(\.isFavorite == false).delete()
    ///
    /// See also the `detachAll(on:)` method.
    public func pivots(on conn: DatabaseConnectable) throws -> QueryBuilder<Base.Database, Through> {
        return try Through.query(on: conn)
            .filter(basePivotField == base.requireID())
    }
}

// MARK: Modifiable Pivot

extension Siblings where Base.Database: QuerySupporting {
    /// Returns true if the supplied model is attached to this relationship.
    public func isAttached(_ model: Related, on conn: DatabaseConnectable) -> Future<Bool> {
        return Future.flatMap(on: conn) {
            return try Through.query(on: conn)
                .filter(self.basePivotField == self.base.requireID())
                .filter(self.relatedPivotField == model.requireID())
                .first()
                .map { $0 != nil }
        }
    }

    /// Detaches the supplied model from this relationship if it was attached.
    ///
    ///     cat.toys.detach(foo, on: conn)
    ///
    /// See `detachAll(on:)` to remove all related models.
    public func detach(_ model: Related, on conn: DatabaseConnectable) -> Future<Void> {
        return Future.flatMap(on: conn) {
            return try Through.query(on: conn)
                .filter(self.basePivotField == self.base.requireID())
                .filter(self.relatedPivotField == model.requireID())
                .delete()
        }
    }

    /// Detaches all attached models from this relationship.
    ///
    ///     cat.toys.detachAll(on: ...)
    ///
    /// See `detach(on:)` to remove a single related models.
    /// See the `pivots(on:)` method to create a `QueryBuilder` on the pivots for more functionality.
    public func detachAll(on conn: DatabaseConnectable) -> Future<Void> {
        return Future.flatMap(on: conn) {
            return try self.pivots(on: conn).delete()
        }
    }
}

/// Left-side
extension Siblings
    where Through: ModifiablePivot, Through.Left == Base, Through.Right == Related, Through.Database: QuerySupporting
{
    /// Attaches the model to this relationship.
    public func attach(_ model: Related, on conn: DatabaseConnectable) -> Future<Through> {
        return Future.flatMap(on: conn) {
            let pivot = try Through(self.base, model)
            return pivot.save(on: conn)
        }
    }
}

/// Right-side
extension Siblings
    where Through: ModifiablePivot, Through.Left == Related, Through.Right == Base, Through.Database: QuerySupporting
{
    /// Attaches the model to this relationship.
    public func attach(_ model: Related, on conn: DatabaseConnectable) -> Future<Through> {
        return Future.flatMap(on: conn) {
            let pivot = try Through(model, self.base)
            return pivot.save(on: conn)
        }
    }
}


// MARK: Model

extension Model {
    /// Create a siblings relation for this model.
    ///
    /// Unless you are doing custom keys, you should not need to
    /// pass any parameters to this function.
    ///
    ///     class Toy: Model {
    ///         var pets: Siblings<Toy, Pet, PetToyPivot> {
    ///             return siblings()
    ///         }
    ///     }
    ///
    /// See Siblings class documentation for more information
    /// about the many parameters. They can be confusing at first!
    ///
    /// - note: From is assumed to be the model you are calling this method on.
    public func siblings<Related, Through>(
        related: Related.Type = Related.self,
        through: Through.Type = Through.self,
        _ basePivotField: WritableKeyPath<Through, Self.ID>,
        _ relatedPivotField: WritableKeyPath<Through, Related.ID>
    ) -> Siblings<Self, Related, Through> {
        return Siblings(
            base: self,
            basePivotField: basePivotField,
            relatedPivotField: relatedPivotField
        )
    }

    /// Free implementation where pivot constraints are met.
    /// See `Model.siblings(_:_:)`.
    public func siblings<Related, Through>(
        related: Related.Type = Related.self,
        through: Through.Type = Through.self
    ) -> Siblings<Self, Related, Through>
        where Through.Right == Self, Through.Left == Related
    {
        return siblings(Through.rightIDKey, Through.leftIDKey)
    }

    /// Free implementation where pivot constraints are met.
    /// See `Model.siblings(_:_:)`.
    public func siblings<Related, Through>(
        related: Related.Type = Related.self,
        through: Through.Type = Through.self
    ) -> Siblings<Self, Related, Through>
        where Through.Left == Self, Through.Right == Related
    {
        return siblings(Through.leftIDKey, Through.rightIDKey)
    }
}

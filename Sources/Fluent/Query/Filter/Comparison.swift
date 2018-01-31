import CodableKit
// MARK: Equality

/// Comparisons that require an equatable value.
public enum EqualityComparison {
    case equals
    case notEquals
}

extension Encodable {
    /// Null
    public static var null: Optional<Self> {
        return nil
    }
}

/// MARK: .equals

/// Model.field == value
public func == <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .equality(.equals), .value(rhs))
    )
}

/// Model.field? == value
public func == <Model, Value>(lhs: KeyPath<Model, Value?>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .equality(.equals), .value(rhs))
    )
}

/// MARK: .notEquals

/// Model.field != value
public func != <Model, Value>(lhs: KeyPath<Model, Value>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .equality(.notEquals), .value(rhs))
    )
}

// MARK: Sequence

/// Comparisons that require a sequence value.
public enum SequenceComparison {
    case hasSuffix
    case hasPrefix
    case contains
}

/// .greaterThan

/// Model.field ~= value
infix operator ~=
public func ~= <Model, Value>(
    lhs: ReferenceWritableKeyPath<Model, Value>,
    rhs: Value
) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .sequence(.hasSuffix), .value(rhs))
    )
}

/// Model.field =~ value
infix operator =~
public func =~ <Model, Value>(lhs: ReferenceWritableKeyPath<Model, Value>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .sequence(.hasPrefix), .value(rhs))
    )
}

/// Model.field ~~ value
infix operator ~~
public func ~~ <Model, Value>(lhs: ReferenceWritableKeyPath<Model, Value>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable, Value: KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .sequence(.contains), .value(rhs))
    )
}

// MARK: Ordered

/// Comparisons that require an ordered value.
public enum OrderedComparison {
    case greaterThan
    case lessThan
    case greaterThanOrEquals
    case lessThanOrEquals
}

/// .greaterThan

/// Model.field > value
public func > <Model, Value>(lhs: ReferenceWritableKeyPath<Model, Value>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .order(.greaterThan), .value(rhs))
    )
}

/// .lessThan

/// Model.field > value
public func < <Model, Value>(lhs: ReferenceWritableKeyPath<Model, Value>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .order(.lessThan), .value(rhs))
    )
}

/// .greaterThanOrEquals

/// Model.field >= value
public func >= <Model, Value>(lhs: ReferenceWritableKeyPath<Model, Value>, rhs: Value) throws -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .order(.greaterThanOrEquals), .value(rhs))
    )
}

/// .lessThanOrEquals

/// Model.field <= value
public func <= <Model, Value>(lhs: ReferenceWritableKeyPath<Model, Value>, rhs: Value) -> ModelFilterMethod<Model>
    where Model: Fluent.Model, Value: Encodable & Equatable & KeyStringDecodable
{
    return ModelFilterMethod<Model>(
        method: .compare(lhs.makeQueryField(), .order(.lessThanOrEquals), .value(rhs))
    )
}

/// Double pivots
/// A pivot in which either the 
/// left or right Entity is another pivot
extension PivotProtocol
    where
        Left: PivotProtocol & Entity,
        Self: Entity,
        Left.Left: Entity,
        Left.Right: Entity,
        Right: Entity
{
    /// Returns true if the three entities
    /// are related by the pivot.
    public static func related(
        left: Left.Left,
        middle: Left.Right,
        right: Right
    ) throws -> Bool {
        let (leftId, middleId, rightId) = try assertSaved(left, middle, right)

        let result = try Left
            .query()
            .join(self)
            .filter(Left.self, Left.Left.foreignIdKey, leftId)
            .filter(Left.self, Left.Right.foreignIdKey, middleId)
            .filter(self, Right.foreignIdKey, rightId)
            .first()

        return result != nil
    }
}

extension PivotProtocol
    where
        Right: PivotProtocol & Entity,
        Self: Entity,
        Left: Entity,
        Right.Left: Entity,
        Right.Right: Entity
{
    /// Returns true if the three entities
    /// are related by the pivot.
    public static func related(
        left: Left,
        middle: Right.Left,
        right: Right.Right
    ) throws -> Bool {
        let (leftId, middleId, rightId) = try assertSaved(left, middle, right)
        
        let result = try Right
            .query()
            .join(self)
            .filter(self, Left.foreignIdKey, leftId)
            .filter(Right.self, Right.Left.foreignIdKey, middleId)
            .filter(Right.self, Right.Right.foreignIdKey, rightId)
            .first()

        return result != nil
    }
}

// MARK: Convenience

private func assertSaved(
    _ left: Entity,
    _ middle: Entity,
    _ right: Entity
) throws -> (Node, Node, Node) {
    guard left.exists else {
        throw PivotError.existRequired(left)
    }

    guard let leftId = left.id else {
        throw PivotError.idRequired(left)
    }

    guard middle.exists else {
        throw PivotError.existRequired(middle)
    }

    guard let middleId = middle.id else {
        throw PivotError.idRequired(middle)
    }

    guard right.exists else {
        throw PivotError.existRequired(right)
    }

    guard let rightId = right.id else {
        throw PivotError.idRequired(right)
    }
    
    return (leftId, middleId, rightId)
}

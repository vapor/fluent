/// Double pivots
///
/// A pivot in which either the 
/// left or right Entity is another pivot
extension PivotProtocol where Left: PivotProtocol, Self: Entity {
    /// Returns true if the three entities
    /// are related by the pivot.
    public static func related(
        left: Left.Left,
        middle: Left.Right,
        right: Right
    ) throws -> Bool {
        let (leftId, middleId, rightId) = try assertIdsExist(left, middle, right)

        let result = try Left
            .query()
            .join(
                self,
                localKey: Left.foreignIdKey,
                foreignKey: Left.idKey
            )
            .filter(Left.self, Left.Left.foreignIdKey, leftId)
            .filter(Left.self, Left.Right.foreignIdKey, middleId)
            .filter(self, Right.foreignIdKey, rightId)
            .first()

        return result != nil
    }
}

extension PivotProtocol where Right: PivotProtocol, Self: Entity {
    /// Returns true if the three entities
    /// are related by the pivot.
    public static func related(
        left: Left,
        middle: Right.Left,
        right: Right.Right
    ) throws -> Bool {
        let (leftId, middleId, rightId) = try assertIdsExist(left, middle, right)

        let result = try Right
            .query()
            .join(
                self,
                localKey: Right.foreignIdKey,
                foreignKey: Right.idKey
            )
            .filter(self, Left.foreignIdKey, leftId)
            .filter(Right.self, Right.Left.foreignIdKey, middleId)
            .filter(Right.self, Right.Right.foreignIdKey, rightId)
            .first()

        return result != nil
    }
}

// MARK: Convenience

private func assertIdsExist(
    _ left: Entity,
    _ middle: Entity,
    _ right: Entity
) throws -> (Node, Node, Node) {
    guard let leftId = left.id else {
        throw PivotError.leftIdRequired
    }

    guard let middleId = middle.id else {
        throw PivotError.middleIdRequired
    }

    guard let rightId = right.id else {
        throw PivotError.rightIdRequired
    }
    
    return (leftId, middleId, rightId)
}

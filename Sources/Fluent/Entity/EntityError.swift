/// Errors that can be thrown when
/// working with entities.
public enum EntityError: Error {
    /// missing database
    case noDatabase(Entity.Type)
    /// All entities from db must have an id
    case noId(Entity.Type)
    /// All entities from
    case doesntExist(Entity.Type)
    /// Reserved for extensions
    case unspecified(Error)

    public var description: String {
        let entity: Entity.Type?
        let reason: String
        switch self {
        case .noDatabase(let e):
            entity = e
            reason = "missing database, make sure to call `database.prepare(\(e).self)` or ensure that it's added to your Droplet's `preparations` with `drop.preprations.append(\(e).self)"
        case .noId(let e):
            entity = e
            reason = "missing id, entities can't exist in a fluent database without their id being set. Make sure you're fetching properly in fluent or setting this manually if necessary."
        case .doesntExist(let e):
            entity = e
            reason = "this object wasn't fetched from the database properly. If you're using custom behavior, make sure to set exists to true after fetching from database"
        case .unspecified(let err):
            entity = nil
            reason = "extension error found - \(err)"
        }

        let type = entity.flatMap { "- \($0) -" } ?? "-"
        return "\(EntityError.self) \(type) \(reason)"
    }
}


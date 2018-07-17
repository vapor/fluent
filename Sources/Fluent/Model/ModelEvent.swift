/// Model lifecycle events.
public enum ModelEvent {
    /// Called before a model is created when saving.
    case willCreate
    /// Called after the model is created when saving.
    case didCreate
    /// Called before a model is updated when saving.
    case willUpdate
    /// Called after the model is updated when saving.
    case didUpdate
    /// Called before a model is fetched.
    case willRead
    /// Called before a model is deleted.
    case willDelete
}

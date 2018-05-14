extension DatabaseQuery {
    /// CRUD operations that can be performed on the database.
    public enum Action {
        /// Saves new data to the database.
        case create
        /// Reads existing data from the database.
        case read
        /// Updates existing data from the database.
        case update
        /// Deletes existing data from the database.
        case delete
    }
}

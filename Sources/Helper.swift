/**
    Subclass `Helper` to provide
    support translating a Fluent `Query`
    to a `Driver`s native database language.
*/
public class Helper<T: Model> {

    /**
        The `Query` that is being
        interpreted by the `Helper`
    */
    var query: Query<T>

    /**
        Creates a new `Helper` with a 
        given `Query`
    */
    public init(query: Query<T>) {
        self.query = query
    }
}
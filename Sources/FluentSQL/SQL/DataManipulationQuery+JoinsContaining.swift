extension DataManipulationQuery: JoinsContaining {
    /// See `JoinsContaining`.
    public typealias Join = DataJoin

    /// See `JoinsContaining`.
    public var fluentJoins: [DataJoin] {
        get { return joins }
        set { joins = newValue }
    }
}

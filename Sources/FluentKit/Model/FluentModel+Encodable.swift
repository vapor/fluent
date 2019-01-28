extension FluentModel where Self: Encodable {
    public func encode(to encoder: Encoder) throws {
        guard let output = self.storage.output as? Encodable else {
            fatalError("No encodable storage output.")
        }
        try output.encode(to: encoder)
    }
}

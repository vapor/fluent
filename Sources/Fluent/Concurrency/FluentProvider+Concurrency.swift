#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore
import Vapor

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Application {
    /// Automatically runs forward migrations without confirmation.
    /// This can be triggered by passing `--auto-migrate` flag.
    public func autoMigrate() async throws {
        try await self.migrator.setupIfNeeded().flatMap {
            self.migrator.prepareBatch()
        }.get()
    }

    /// Automatically runs reverse migrations without confirmation.
    /// This can be triggered by passing `--auto-revert` during boot.
    public func autoRevert() async throws {
        try await self.migrator.setupIfNeeded().flatMap {
            self.migrator.revertAllBatches()
        }.get()
    }
}

#endif

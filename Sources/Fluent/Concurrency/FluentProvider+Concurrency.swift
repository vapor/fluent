import Vapor
import FluentKit

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

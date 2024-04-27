import NIOCore
import Vapor
import FluentKit

extension ModelCredentialsAuthenticatable {
    public static func asyncCredentialsAuthenticator(
        _ database: DatabaseID? = nil
    ) -> any AsyncAuthenticator {
        AsyncModelCredentialsAuthenticator<Self>(database: database)
    }
}

private struct AsyncModelCredentialsAuthenticator<User>: AsyncCredentialsAuthenticator
    where User: ModelCredentialsAuthenticatable
{
    typealias Credentials = ModelCredentials

    public let database: DatabaseID?

    func authenticate(credentials: ModelCredentials, for request: Request) async throws {
        if let user = try await User.query(on: request.db(self.database)).filter(\._$username == credentials.username).first() {
            guard try user.verify(password: credentials.password) else {
                return
            }
            request.auth.login(user)
        }
    }
}

#if compiler(>=5.5) && canImport(_Concurrency)
import NIOCore
import Vapor

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension ModelCredentialsAuthenticatable {
    public static func asyncCredentialsAuthenticator(
        _ database: DatabaseID? = nil
    ) -> AsyncAuthenticator {
        AsyncModelCredentialsAuthenticator<Self>(database: database)
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
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

#endif


//
//  MockAuthService.swift
//  AIChat
//
//  Created by David Wright on 4/28/25.
//

import Foundation

@MainActor
public class MockAuthService: AuthService {

    @Published private(set) var currentUser: UserAuthInfo?

    public init(user: UserAuthInfo? = nil) {
        self.currentUser = user
    }

    public func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)

            Task {
                for await value in $currentUser.values {
                    continuation.yield(value)
                }
            }
        }
    }

    public func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {

    }

    public func getAuthenticatedUser() -> UserAuthInfo? {
        currentUser
    }
    
    public func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: true)
        currentUser = user
        return (user, true)
    }
    
    public func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    public func signOut() throws {
        currentUser = nil
    }
    
    public func deleteAccount() async throws {
        currentUser = nil
    }
}

//
//  FirebaseAuthService.swift
//  AIChat
//
//  Created by David Wright on 4/28/25.
//

@preconcurrency import FirebaseAuth
import SignInAppleAsync

@MainActor
public struct FirebaseAuthService: AuthService {

    public init() { }

    public func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }

            onListenerAttached(listener)
        }
    }

    public func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
    }

    public func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }

    public func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }

    public func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()

        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )

        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                // Try to link to existing anonymous account
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await Auth.auth().signIn(with: secondaryCredential)
                        return result.asAuthInfo
                    }
                default:
                    break
                }
            }
        }

        // Otherwise sign in to new account
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }

    public func signOut() throws {
        try Auth.auth().signOut()
    }

    public func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }

        do {
            try await user.delete()
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)
            switch authError {
            case .requiresRecentLogin:
                // Try to reauthenticate user.
                try await reauthenticateUser(error: error)

                // Reauthentication successful, try to delete account again.
                try await user.delete()
            default:
                throw error
            }
        }
    }

    private func reauthenticateUser(error: Error) async throws {
        guard let user = Auth.auth().currentUser, let providerID = user.providerData.first?.providerID else {
            throw AuthError.userNotFound
        }

        switch providerID {
        case "apple.com":
            let result = try await signInApple()

            guard user.uid == result.user.uid else {
                throw AuthError.reauthAccountChanged
            }
        default:
            throw error
        }
    }

    public enum AuthError: LocalizedError {
        case userNotFound
        case reauthAccountChanged

        public var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Current authenticated user not found."
            case .reauthAccountChanged:
                return "Reauthenticated switched accounts. Please check your account."
            }
        }
    }
}

extension AuthDataResult {

    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        return (user, isNewUser)
    }
}

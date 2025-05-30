//
//  AuthManager.swift
//  AIChat
//
//  Created by David Wright on 4/28/25.
//

import SwiftUI

@MainActor
@Observable
public class AuthManager {

    private let service: AuthService
    private let logger: AuthLogger?
    public private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?

    public init(service: AuthService, logger: AuthLogger? = nil) {
        self.service = service
        self.logger = logger
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }

    private func addAuthListener() {
        logger?.trackEvent(event: Event.authListenerStart)

        if let listener {
            service.removeAuthenticatedUserListener(listener: listener)
        }

        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.auth = value
                logger?.trackEvent(event: Event.authListenerSuccess(user: value))

                if let value {
                    logger?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logger?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                }
            }
        }
    }

    public func getAuthId() throws -> String {
        guard let uid = auth?.uid else { throw AuthError.notSignedIn }
        return uid
    }

    public func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await service.signInAnonymously()
        self.auth = result.user
        return result
    }

    public func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        defer {
            addAuthListener()
        }
        let result = try await service.signInApple()
        self.auth = result.user
        return result
    }

    public func signOut() throws {
        logger?.trackEvent(event: Event.signOutStart)

        try service.signOut()
        auth = nil
        logger?.trackEvent(event: Event.signOutSuccess)
    }

    public func deleteAccount() async throws {
        logger?.trackEvent(event: Event.deleteAccountStart)

        try await service.deleteAccount()
        auth = nil
        logger?.trackEvent(event: Event.deleteAccountSuccess)
    }

    public enum AuthError: LocalizedError {
        case notSignedIn
    }
}

extension AuthManager {

    enum Event: AuthLogEvent {
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfo?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess

        var eventName: String {
            switch self {
            case .authListenerStart:        "AuthMgr_AuthListener_Start"
            case .authListenerSuccess:      "AuthMgr_AuthListener_Success"
            case .signOutStart:             "AuthMgr_SignOut_Start"
            case .signOutSuccess:           "AuthMgr_SignOut_Success"
            case .deleteAccountStart:       "AuthMgr_DeleteAccount_Start"
            case .deleteAccountSuccess:     "AuthMgr_DeleteAccount_Success"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(let user):
                return user?.eventParameters
            default:
                return nil
            }
        }

        var type: AuthLogType {
            switch self {
            default: .analytic
            }
        }
    }
}

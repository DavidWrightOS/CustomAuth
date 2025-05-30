//
//  UserAuthInfo.swift
//  AIChat
//
//  Created by David Wright on 4/28/25.
//

import SwiftUI

public struct UserAuthInfo: Sendable, Codable {

    public let uid: String
    public let email: String?
    public let isAnonymous: Bool
    public let creationDate: Date?
    public let lastSignInDate: Date?

    public init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }

    public enum CodingKeys: String, CodingKey {
        case uid
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
    }

    public static func mock(isAnonymous: Bool = false) -> Self {
        UserAuthInfo(
            uid: "mock_user_123",
            email: "hello@email.com",
            isAnonymous: isAnonymous,
            creationDate: Date(),
            lastSignInDate: Date()
        )
    }

    public var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "uauth_\(CodingKeys.uid.rawValue)": uid,
            "uauth_\(CodingKeys.email.rawValue)": email,
            "uauth_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "uauth_\(CodingKeys.creationDate.rawValue)": creationDate,
            "uauth_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
        ]
        return dict.compactMapValues({ $0 })
    }
}

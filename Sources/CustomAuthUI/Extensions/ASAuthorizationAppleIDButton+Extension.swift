//
//  ASAuthorizationAppleIDButton+Extension.swift
//  CustomAuth
//
//  Created by David Wright on 5/30/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

extension ASAuthorizationAppleIDButton.Style {
    static var allCases: [Self] {
        [.black, .white, .whiteOutline]
    }
}

extension ASAuthorizationAppleIDButton.ButtonType {
    static var allCases: [Self] {
        [.signIn, .signUp, .continue, .default]
    }

    var buttonText: String {
        switch self {
        case .signIn:
            return "Sign in with"
        case .continue:
            return "Continue with"
        case .signUp:
            return "Sign up with"
        default:
            return "Sign in with"
        }
    }
}

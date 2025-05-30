//
//  AuthLogger.swift
//  CustomAuth
//
//  Created by David Wright on 5/30/25.
//

@MainActor
public protocol AuthLogger {
    func trackEvent(event: AuthLogEvent)
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
}

public protocol AuthLogEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: AuthLogType { get }
}

public enum AuthLogType: Int {
    case info // 0
    case analytic // 1
    case warning // 2
    case severe // 3

    var emoji: String {
        switch self {
        case .info: "👋"
        case .analytic: "📈"
        case .warning: "⚠️"
        case .severe: "🚨"
        }
    }

    var asString: String {
        switch self {
        case .info: "info"
        case .analytic: "analytic"
        case .warning: "warning"
        case .severe: "severe"
        }
    }
}

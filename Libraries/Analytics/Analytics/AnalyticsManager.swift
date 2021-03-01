//
//  Configuration.swift
//  Analytics
//
//  Created by Varun Santhanam on 1/31/21.
//

import Countly
import Foundation
import Logging
import os.log

/// @mockable
public protocol AnalyticsManaging: AnyObject {
    func send(event: String, segmentation: [String: String]?)
}

public extension AnalyticsManaging {
    func send(event: String) {
        send(event: event, segmentation: nil)
    }
}

public struct AnalyticsConfig: Codable {
    public let appKey: String?
    public let host: String?
}

public final class AnalyticsManager: AnalyticsManaging {

    // MARK: - API

    /// The shared instance
    public static let shared: AnalyticsManager = .init()

    /// Whether or not analytics events are accepted
    public private(set) var isStarted: Bool = false

    /// Start the analytics manager
    /// - Parameter config: The configuration, used to determine where to send events
    public func startAnalytics(with config: AnalyticsConfig) {
        guard let appKey = config.appKey,
            let host = config.host else {
            return
        }
        let countlyConfig = CountlyConfig()
        countlyConfig.appKey = appKey
        countlyConfig.host = host
        countlyConfig.features = [.crashReporting]
        Countly.sharedInstance().start(with: countlyConfig)
        isStarted = true
    }

    /// Stop the analytics manager
    public func stopAnalytics() {
        isStarted = false
    }

    // MARK: - AnalyticsManaging

    /// Send an event
    /// - Parameters:
    ///   - event: The event
    ///   - segmentation: The segmentation data
    public func send(event: String, segmentation: [String: String]? = nil) {
        guard isStarted else {
            return
        }

        Countly.sharedInstance().recordEvent(event, segmentation: segmentation)
        if let segmentation = segmentation {
            os_log("Sending event: %{public}@ with %{public}@", log: .analytics, type: .info, event, segmentation as! CVarArg)
        } else {
            os_log("Sending event: %{public}@", log: .analytics, type: .info, event)
        }
    }

    // MARK: - Private

    internal func logAssertError(key: String, file: StaticString, function: StaticString, line: UInt) {
        guard isStarted else {
            return
        }
        let meta = ["key": "\(key)",
                    "file": "\(file)",
                    "function": "\(function)",
                    "line": String(line)]
        send(event: "failure-\(key)", segmentation: meta)
    }

    internal func logFatalError(key: String, file: StaticString, function: StaticString, line: UInt) {
        guard isStarted else {
            return
        }
        let meta = ["key": "\(key)",
                    "file": "\(file)",
                    "function": "\(function)",
                    "line": String(line)]
        send(event: "fatal-\(key)", segmentation: meta)
    }

}

public enum Analytics {

    /// Send an event
    /// - Parameters:
    ///   - event: The event
    ///   - segmentation: The segmentation data
    public static func send(event: String, segmentation: [String: String]? = nil) {
        AnalyticsManager.shared.send(event: event, segmentation: segmentation)
    }
}

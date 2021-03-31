//
// ScoreFive
// Varun Santhanam
//

import Countly
import Foundation
import Logging
import os.log

public protocol Event: Equatable {
    var key: String { get }
}

/// @mockable
public protocol AnalyticsManaging: AnyObject {
    func send<T>(event: T, segmentation: [String: String]?) where T: Event
}

public extension AnalyticsManaging {
    func send<T>(event: T) where T: Event {
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

    /// Event Prefix
    public var eventPrefix: String = ""

    /// Start the analytics manager
    /// - Parameter config: The configuration, used to determine where to send events
    public func startAnalytics(with config: AnalyticsConfig) {
        guard let appKey = config.appKey,
              let host = config.host
        else {
            guard AnalyticsEnvironment[.allowAnonymousAnalytics] == true else {
                fatalError("""
                Empty or invalid analytics configuration! Run `./sftool analytics install` or run the app with EV `AN_ALLOW_ANONYMOUS_ANALYTICS` as `YES`
                """)
            }
            isStarted = true
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
    public func send<T>(event: T, segmentation: [String: String]?) where T: Event {
        send(key: event.key, segmentation: segmentation)
    }

    // MARK: - Private

    internal func logAssertError(key: String, file: StaticString, function: StaticString, line: UInt) {
        let meta = ["key": "\(key)",
                    "file": "\(file)",
                    "function": "\(function)",
                    "line": String(line)]
        send(key: "failure-\(key)", segmentation: meta)
    }

    internal func logFatalError(key: String, file: StaticString, function: StaticString, line: UInt) {
        let meta = ["key": "\(key)",
                    "file": "\(file)",
                    "function": "\(function)",
                    "line": String(line)]
        send(key: "fatal-\(key)", segmentation: meta)
    }

    private func send(key: String, segmentation: [String: String]? = nil) {
        guard isStarted else {
            assertionFailure("Attempt to log event \(key) without active analytics manager!")
            return
        }

        let key = eventPrefix + key

        #if targetEnvironment(simulator)
            os_log("Ignoring event: %{public}@", log: .analytics, type: .info, key)
        #else
            os_log("Sending event: %{public}@", log: .analytics, type: .info, key)
            Countly.sharedInstance().recordEvent(key, segmentation: segmentation)
        #endif
    }

}

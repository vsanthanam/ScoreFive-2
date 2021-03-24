//
// ScoreFive
// Varun Santhanam
//

import AppFoundation

enum EnvironmentVariablesAnanalytics: EnvironmentVariable {

    // MARK: - API

    case allowAnonymousAnalytics

    // MARK: - EnvironmentVariable

    static var namespace: String? {
        "AN"
    }

    var key: String {
        switch self {
        case .allowAnonymousAnalytics:
            return "ALLOW_ANONYMOUS_ANALYTICS"
        }
    }
}

typealias AnalyticsEnvironment = BaseEnvironment<EnvironmentVariablesAnanalytics>

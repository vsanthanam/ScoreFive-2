//
// ScoreFive
// Varun Santhanam
//

import Analytics
import Foundation

enum AnalyticsEvent: String, Event {
    case app_launch
    case app_tree_activated
    var key: String { rawValue }
}

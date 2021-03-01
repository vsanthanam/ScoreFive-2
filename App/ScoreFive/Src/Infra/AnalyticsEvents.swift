//
//  Events.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 3/1/21.
//

import Analytics
import Foundation

enum AnalyticsEvent: String, Event {
    case app_launch
    case app_tree_activated
    var key: String { rawValue }
}

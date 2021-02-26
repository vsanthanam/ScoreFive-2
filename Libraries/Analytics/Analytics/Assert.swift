//
//  Assert.swift
//  Analytics
//
//  Created by Varun Santhanam on 1/31/21.
//

import Foundation

public func loggedAssert(_ condition: Bool, _ message: String, key: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    AnalyticsManager.shared.logAssertError(key: key, file: file, function: function, line: line)
    assert(condition, message, file: file, line: line)
}

public func loggedAssertionFailure(_ message: String, key: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    AnalyticsManager.shared.logAssertError(key: key, file: file, function: function, line: line)
    assertionFailure(message, file: file, line: line)
}

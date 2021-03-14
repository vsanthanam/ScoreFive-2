//
//  Logging.swift
//  Logging
//
//  Created by Varun Santhanam on 2/28/21.
//

import Foundation
import os.log

public extension OSLog {
    static let standard: OSLog = .init(subsystem: .subsystem, category: "ScoreFive")
    static let analytics: OSLog = .init(subsystem: .subsystem, category: "Analytics")
}

private extension String {
    static var subsystem: String { "com.vsanthanam.ScoreFive" }
}

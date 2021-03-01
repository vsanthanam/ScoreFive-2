//
//  Logging.swift
//  Logging
//
//  Created by Varun Santhanam on 2/28/21.
//

import Foundation
import os.log
import ShortRibs

extension OSLog {
    public static let standard: OSLog = .init(subsystem: .subsystem, category: "ScoreFive")
    public static let analytics: OSLog = .init(subsystem: .subsystem, category: "Analytics")
}

private extension String {
    static var subsystem: String { "com.vsanthanam.ScoreFive" }
}

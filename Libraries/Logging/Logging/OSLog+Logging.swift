//
// ScoreFive
// Varun Santhanam
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

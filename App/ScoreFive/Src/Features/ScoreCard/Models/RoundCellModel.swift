//
// ScoreFive
// Varun Santhanam
//

import Foundation

struct RoundCellModel: Equatable, Hashable {
    let visibleIndex: String?
    let index: Int
    let scores: [Int?]
    let canRemove: Bool
}

//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

open class TappableControl: BaseControl {

    // MARK: - UIControl

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isHighlighted = true
        return true
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        isHighlighted = bounds.contains(point)
        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isHighlighted = false
    }

}

//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

open class TappableControl: BaseControl {

    // MARK: - UIControl

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let shouldTrack = super.beginTracking(touch, with: event)
        isHighlighted = !shouldTrack
        return shouldTrack
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isHighlighted = false
        super.endTracking(touch, with: event)
    }

    override open func cancelTracking(with event: UIEvent?) {
        isHighlighted = false
        super.cancelTracking(with: event)
    }

}

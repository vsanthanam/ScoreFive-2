//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

/// A beneric `UIControl` subclass
open class BaseControl: UIControl {

    /// Create a `BaseControl`
    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError()
    }

}

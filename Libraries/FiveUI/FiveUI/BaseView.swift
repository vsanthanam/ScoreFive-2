//
// ScoreFive
// Varun Santhanam
//

import Foundation
import UIKit

/// A generic view subclass
open class BaseView: UIView {

    /// Create a `BaseView`
    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError()
    }

}

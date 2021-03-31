//
// ScoreFive
// Varun Santhanam
//

import Analytics
import FiveUI
import Foundation
import ShortRibs
import UIKit

/// @mockable
protocol FiveViewControllable: ViewControllable {}

/// @mockable
protocol FivePresentableListener: AnyObject {}

final class FiveViewController: ParentNavigationController, FivePresentable, FiveViewControllable {

    // MARK: - FivePresentable

    weak var listener: FivePresentableListener?

    func showHome(_ viewController: ViewControllable) {
        embedActiveChild(viewController, with: .pop)
    }

    func showGame(_ viewController: ViewControllable) {
        embedActiveChild(viewController, with: .push)
    }
}

//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShortRibs

/// @mockable
protocol MoreOptionsPresentable: MoreOptionsViewControllable {
    var listener: MoreOptionsPresentableListener? { get set }
}

/// @mockable
protocol MoreOptionsListener: AnyObject {
    func moreOptionsDidResign()
}

final class MoreOptionsInteractor: PresentableInteractor<MoreOptionsPresentable>, MoreOptionsInteractable, MoreOptionsPresentableListener {

    override init(presenter: MoreOptionsPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: MoreOptionsListener?

    // MARK: - MoreOptionsPresentableListener

    func didTapClose() {
        listener?.moreOptionsDidResign()
    }
}

//
//  MoreInteractor.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 2/10/21.
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

    // MARK: - API

    weak var listener: MoreOptionsListener?

    // MARK: - MoreOptionsPresentableListener

    func didTapClose() {
        listener?.moreOptionsDidResign()
    }
}

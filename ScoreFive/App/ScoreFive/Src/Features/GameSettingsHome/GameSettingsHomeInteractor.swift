//
// ScoreFive
// Varun Santhanam
//

import Combine
import CombineSchedulers
import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol GameSettingsHomePresentable: GameSettingsHomeViewControllable {
    var listener: GameSettingsHomePresentableListener? { get set }
}

/// @mockable
protocol GameSettingsHomeListener: AnyObject {
    func gameSettingsHomeDidResign()
}

final class GameSettingsHomeInteractor: PresentableInteractor<GameSettingsHomePresentable>, GameSettingsHomeInteractable, GameSettingsHomePresentableListener {

    override init(presenter: GameSettingsHomePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: GameSettingsHomeListener?

    // MARK: - GameSettingsHomePresentableListener

    func didTapClose() {
        listener?.gameSettingsHomeDidResign()
    }
}

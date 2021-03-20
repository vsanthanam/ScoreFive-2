//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShortRibs

/// @mockable
protocol GameSettingsPresentable: GameSettingsViewControllable {
    var listener: GameSettingsPresentableListener? { get set }
}

/// @mockable
protocol GameSettingsListener: AnyObject {
    func gameSettingsDidResign()
}

final class GameSettingsInteractor: PresentableInteractor<GameSettingsPresentable>, GameSettingsInteractable, GameSettingsPresentableListener {

    override init(presenter: GameSettingsPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - API

    weak var listener: GameSettingsListener?

    // MARK: - GameSettingsPresentableListener

    func didTapClose() {
        listener?.gameSettingsDidResign()
    }
}

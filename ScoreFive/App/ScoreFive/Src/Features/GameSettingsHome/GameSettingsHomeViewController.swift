//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ScoreKeeping
import ShortRibs
import UIKit

/// @mockable
protocol GameSettingsHomeViewControllable: ViewControllable {}

/// @mockable
protocol GameSettingsHomePresentableListener: AnyObject {
    func didTapClose()
}

final class GameSettingsHomeViewController: ScopeViewController, GameSettingsHomePresentable, GameSettingsHomeViewControllable {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    // MARK: - GameSettingsHomePresentable

    weak var listener: GameSettingsHomePresentableListener?

    // MARK: - Private

    private func setUp() {
        specializedView.backgroundColor = .backgroundPrimary

        title = "Game Settings"
        let leadingItem = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(didTapClose))
        navigationItem.leftBarButtonItem = leadingItem
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc
    private func didTapClose() {
        listener?.didTapClose()
    }
}

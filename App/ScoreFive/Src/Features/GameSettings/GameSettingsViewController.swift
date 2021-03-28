//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShortRibs
import UIKit

/// @mockable
protocol GameSettingsViewControllable: ViewControllable {}

/// @mockable
protocol GameSettingsPresentableListener: AnyObject {}

final class GameSettingsViewController: ParentNavigationController, GameSettingsPresentable, GameSettingsViewControllable {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        setUp()
    }

    // MARK: - GameSettingsPresentable

    weak var listener: GameSettingsPresentableListener?

    func showGameSettingsHome(_ viewController: ViewControllable) {
        embedActiveChild(viewController, with: .push)
    }

    private func setUp() {
        navigationController?.navigationBar.prefersLargeTitles = true
        setBarColor(.backgroundPrimary)
    }

}

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
protocol GameSettingsPresentableListener: AnyObject {
    func didTapClose()
}

final class GameSettingsViewController: ScopeViewController, GameSettingsPresentable, GameSettingsViewControllable, UINavigationBarDelegate {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    // MARK: - GameSettingsPresentable

    weak var listener: GameSettingsPresentableListener?

    // MARK: - UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: - Private

    private let header = UINavigationBar()

    private func setUp() {
        isModalInPresentation = true
        specializedView.backgroundColor = .backgroundPrimary

        let navigationItem = UINavigationItem(title: "Game Settings")
        navigationItem.largeTitleDisplayMode = .always

        let closeItem = UIBarButtonItem(barButtonSystemItem: .close,
                                        target: self,
                                        action: #selector(close))
        navigationItem.leftBarButtonItem = closeItem

        header.setItems([navigationItem], animated: false)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundPrimary

        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 10 // This is added to the default margin
        appearance.largeTitleTextAttributes = [.paragraphStyle: style]

        header.scrollEdgeAppearance = appearance
        header.delegate = self
        header.prefersLargeTitles = true

        specializedView.addSubview(header)

        header.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalToSuperview()
            make
                .top
                .equalTo(specializedView.safeAreaLayoutGuide)
        }
    }

    @objc
    private func close() {
        listener?.didTapClose()
    }
}

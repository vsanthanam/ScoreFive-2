//
// ScoreFive
// Varun Santhanam
//

import Foundation
import ShortRibs
import UIKit

/// @mockable
protocol MoreOptionsViewControllable: ViewControllable {}

/// @mockable
protocol MoreOptionsPresentableListener: AnyObject {
    func didTapClose()
}

final class MoreOptionsViewController: ScopeViewController, MoreOptionsPresentable, MoreOptionsViewControllable, UINavigationBarDelegate {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        setUp()
    }

    // MARK: - MoreOptionsPresentable

    weak var listener: MoreOptionsPresentableListener?

    // MARK: - UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: - Private

    private let header = UINavigationBar()

    private func setUp() {
        specializedView.backgroundColor = .backgroundPrimary
        let navigationItem = UINavigationItem(title: "Settings")
        let closeItem = UIBarButtonItem(barButtonSystemItem: .close,
                                        target: self,
                                        action: #selector(didTapClose))
        navigationItem.leftBarButtonItem = closeItem
        navigationItem.largeTitleDisplayMode = .always
        header.setItems([navigationItem], animated: false)
        header.delegate = self
        header.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundPrimary
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 10 // This is added to the default margin
        appearance.largeTitleTextAttributes = [.paragraphStyle: style]
        header.scrollEdgeAppearance = appearance
        header.delegate = self
        specializedView.addSubview(header)

        header.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .top
                .equalToSuperview()
        }
    }

    @objc
    private func didTapClose() {
        listener?.didTapClose()
    }

}

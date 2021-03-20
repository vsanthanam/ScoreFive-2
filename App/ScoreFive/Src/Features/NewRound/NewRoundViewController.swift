//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import ScoreKeeping
import ShortRibs
import SnapKit
import UIKit

/// @mockable
protocol NewRoundViewControllable: ViewControllable {}

/// @mockable
protocol NewRoundPresentableListener: AnyObject {
    func didTapClose()
    func didInputScore(_ score: Int)
    func didSaveScore(_ score: Int)
    func didRegress()
    func didProgress()
}

final class NewRoundViewController: ScopeViewController, NewRoundPresentable, NewRoundViewControllable, UINavigationBarDelegate, RoundScoreViewDelegate {

    enum Transition {
        case forward
        case backward
        case error
        case instant
    }

    // MARK: - Initializers

    init(replacing: Bool) {
        self.replacing = replacing
        super.init(ScopeView.init)
        isModalInPresentation = true
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        startObservingKeyboardNotifications()
        setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        entryView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        entryView.resignFirstResponder()
    }

    // MARK: - NewRoundPresentable

    weak var listener: NewRoundPresentableListener?

    func setVisibleScore(_ score: Int?, with transition: NewRoundViewController.Transition) {
        let newValue: String?

        if let score = score {
            newValue = score == Round.noScore ? "" : String(score)
        } else {
            newValue = nil
        }

        switch transition {
        case .error:
            entryView.shake(newValue: newValue)
        case .forward:
            entryView.advance(newValue: newValue)
        case .backward:
            entryView.regress(newValue: newValue)
        case .instant:
            entryView.visibleScore = newValue ?? ""
        }
    }

    func setPlayerName(_ name: String?) {
        entryView.visibleTitle = name ?? ""
    }

    func showResetError() {
        let alertController = UIAlertController(title: "Error",
                                                message: "You can't edit a round by this much!",
                                                preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK",
                                        style: .default,
                                        handler: nil)
        alertController.addAction(alertAction)
        present(alertController,
                animated: true,
                completion: nil)
    }

    // MARK: - UINavigationBarDelegate

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .topAttached
    }

    // MARK: - RoundScoreViewDelegate

    func scoreValueChanged(_ input: String) {
        guard input != "" else {
            return
        }
        guard let integer = Int(input) else {
            entryView.shake()
            return
        }
        listener?.didInputScore(integer)
    }

    func scoreDidAccept() {
        guard let score = Int(entryView.visibleScore) else {
            return
        }
        listener?.didSaveScore(score)
    }

    func scoreDidRegress() {
        listener?.didRegress()
    }

    func scoreDidProgress() {
        listener?.didProgress()
    }

    // MARK: - Private

    private let replacing: Bool
    private let header = UINavigationBar()
    private let entryView = RoundScoreView()
    private let keyboardLayoutGuide = UILayoutGuide()

    private var keyboardConstraint: Constraint?

    private func setUp() {
        specializedView.addLayoutGuide(keyboardLayoutGuide)
        specializedView.backgroundColor = .backgroundPrimary

        let navigationItem = UINavigationItem(title: replacing ? "Edit Scores" : "Add Scores")
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

        keyboardLayoutGuide.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalToSuperview()
            make
                .top
                .equalTo(header.snp.bottom)
            keyboardConstraint = make
                .bottom
                .equalToSuperview()
                .constraint
        }

        specializedView.addSubview(entryView)
        entryView.snp.makeConstraints { make in
            make
                .center
                .equalTo(keyboardLayoutGuide)
            make
                .leading
                .trailing
                .equalTo(keyboardLayoutGuide)
        }
        entryView.delegate = self
    }

    @objc
    private func close() {
        listener?.didTapClose()
    }

    private func startObservingKeyboardNotifications() {
        UIResponder.keyboardWillHideNotification
            .asPublisher()
            .sink { notif in
                self.handleKeyboardNotification(notif)
            }
            .cancelOnDeinit(self)
        UIResponder.keyboardWillChangeFrameNotification
            .asPublisher()
            .sink { notif in
                self.handleKeyboardNotification(notif)
            }
            .cancelOnDeinit(self)
    }

    private func handleKeyboardNotification(_ notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            keyboardConstraint?.update(inset: 0.0)
        } else {
            keyboardConstraint?.update(inset: keyboardViewEndFrame.height - view.safeAreaInsets.bottom)
        }
    }
}

//
// ScoreFive
// Varun Santhanam
//

import FiveUI
import Foundation
import ShortRibs
import UIKit

/// @mockable
protocol GameViewControllable: ViewControllable {}

/// @mockable
protocol GamePresentableListener: AnyObject {
    func wantNewRound()
    func didClose()
    func wantGameSettings()
}

final class GameViewController: ScopeViewController, GamePresentable, GameViewControllable {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - GamePresentable

    weak var listener: GamePresentableListener?

    func showNewRound(_ viewController: ViewControllable) {
        if let current = newRoundViewController {
            current.uiviewController.dismiss(animated: true) { [weak self] in
                self?.newRoundViewController = nil
                self?.showNewRound(viewController)
            }
        } else {
            present(viewController.uiviewController, animated: true) { [weak self] in
                self?.newRoundViewController = viewController
            }
        }
    }

    func closeNewRound() {
        newRoundViewController?.uiviewController.dismiss(animated: true, completion: nil)
        newRoundViewController = nil
    }

    func showGameSettings(_ viewController: ViewControllable) {
        if let current = gameSettingsViewController {
            current.uiviewController.dismiss(animated: true) { [weak self] in
                self?.gameSettingsViewController = nil
                self?.showGameSettings(viewController)
            }
        } else {
            present(viewController.uiviewController, animated: true) { [weak self] in
                self?.gameSettingsViewController = viewController
            }
        }
    }

    func closeGameSettings() {
        gameSettingsViewController?.uiviewController.dismiss(animated: true, completion: nil)
        gameSettingsViewController = nil
    }

    func showScoreCard(_ viewController: ScoreCardViewControllable) {
        if let current = scoreCardViewController {
            current.uiviewController.willMove(toParent: nil)
            current.uiviewController.view.removeFromSuperview()
            current.uiviewController.removeFromParent()
            scoreCardViewController = nil
        }
        addChild(viewController.uiviewController)
        view.addSubview(viewController.uiviewController.view)
        viewController.uiviewController.view.snp.makeConstraints { make in
            make
                .edges
                .equalTo(scoreCardLayoutGuide)
        }
        viewController.uiviewController.didMove(toParent: self)
    }

    func updateHeaderTitles(_ titles: [String]) {
        gameHeader.apply(names: titles)
    }

    func updateTotalScores(_ scores: [String], min: String, max: String) {
        gameFooter.apply(scores: scores, positiveLabel: min, negativeLabel: max)
    }

    // MARK: - Private

    private let bottomSpacer = ScopeView()
    private let gameHeader = GameHeaderView()
    private let gameFooter = GameFooterView()
    private let addRoundButton = AddRoundButton()
    private let scoreCardLayoutGuide = UILayoutGuide()

    private var newRoundViewController: ViewControllable?
    private var gameSettingsViewController: ViewControllable?
    private var scoreCardViewController: ScoreCardViewControllable?

    private func setUp() {
        title = "Score Card"
        let leadingItem = UIBarButtonItem(barButtonSystemItem: .close,
                                          target: self,
                                          action: #selector(didTapClose))

        let trailingItem = UIBarButtonItem.fromSymbol(named: "ellipsis",
                                                      target: self,
                                                      action: #selector(didTapActions))
        trailingItem.tintColor = .contentPrimary

        navigationItem.leftBarButtonItem = leadingItem
        navigationItem.rightBarButtonItem = trailingItem
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setNavigationBarHidden(false, animated: true)
        specializedView.addLayoutGuide(scoreCardLayoutGuide)

        addRoundButton.addTarget(self, action: #selector(didTapAddRound), for: .touchUpInside)
        specializedView.addSubview(addRoundButton)
        bottomSpacer.backgroundColor = .contentAccentPrimary

        specializedView.addSubview(bottomSpacer)
        specializedView.addSubview(gameHeader)
        specializedView.addSubview(gameFooter)

        gameHeader.snp.makeConstraints { make in
            make
                .top
                .equalToSuperview()
            make
                .leading
                .trailing
                .equalTo(specializedView.safeAreaLayoutGuide)
        }

        scoreCardLayoutGuide.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalTo(specializedView.safeAreaLayoutGuide)
            make
                .top
                .equalTo(gameHeader.snp.bottom)
            make
                .bottom
                .equalTo(gameFooter.snp.top)
        }

        gameHeader.setContentHuggingPriority(.required, for: .vertical)
        gameFooter.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalTo(specializedView.safeAreaLayoutGuide)
            make
                .bottom
                .equalTo(addRoundButton.snp.top)
        }

        addRoundButton.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalToSuperview()
            make
                .bottom
                .equalTo(specializedView.safeAreaLayoutGuide.snp.bottom)
        }

        bottomSpacer.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .bottom
                .equalToSuperview()
            make
                .top
                .equalTo(specializedView.safeAreaLayoutGuide.snp.bottom)
        }
    }

    @objc
    private func didTapAddRound() {
        listener?.wantNewRound()
    }

    @objc
    private func didTapClose() {
        listener?.didClose()
    }

    @objc
    private func didTapActions() {
        listener?.wantGameSettings()
    }
}

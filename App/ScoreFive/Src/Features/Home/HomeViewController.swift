//
//  HomeViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/29/20.
//

import FiveUI
import Foundation
import ScoreKeeping
import ShortRibs
import UIKit

/// @mockable
protocol HomeViewControllable: ViewControllable {}

/// @mockable
protocol HomePresentableListener: AnyObject {
    func didTapNewGame()
    func didTapResumeLastGame()
    func didTapLoadGame()
    func didTapMore()
}

final class HomeViewController: ScopeViewController, HomePresentable, HomeViewControllable {

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - HomePresentable

    weak var listener: HomePresentableListener?

    func showResumeButton() {
        confineTo(viewEvents: [.viewDidLoad], once: true) { [weak self] in
            guard let self = self else { return }
            if let previous = self.resumeGameButton {
                self.buttonStackView.removeArrangedSubview(previous)
                self.resumeGameButton = nil
            }
            let button = HomeButton(title: "Resume Last Game")
            button.addTarget(self, action: #selector(self.didTapResume), for: .touchUpInside)
            self.buttonStackView.addArrangedSubview(button)
            self.resumeGameButton = button
        }
    }

    func hideResumeButton() {
        confineTo(viewEvents: [.viewDidLoad], once: true) { [weak self] in
            guard let self = self else { return }
            guard let previous = self.resumeGameButton else { return }
            self.buttonStackView.removeArrangedSubview(previous)
            self.resumeGameButton = nil
        }
    }

    func showLoadButton() {
        confineTo(viewEvents: [.viewDidLoad], once: true) { [weak self] in
            guard let self = self else { return }
            if let previous = self.loadGameButton {
                self.buttonStackView.removeArrangedSubview(previous)
                self.loadGameButton = nil
            }
            let button = HomeButton(title: "Load Game")
            button.addTarget(self, action: #selector(self.didTapLoad), for: .touchUpInside)
            self.buttonStackView.addArrangedSubview(button)
            self.loadGameButton = button
        }
    }

    func hideLoadButton() {
        confineTo(viewEvents: [.viewDidLoad], once: true) { [weak self] in
            guard let self = self else { return }
            guard let previous = self.loadGameButton else { return }
            self.buttonStackView.removeArrangedSubview(previous)
            self.loadGameButton = nil
        }
    }

    func showNewGame(_ viewController: ViewControllable) {
        confineTo(viewEvents: [.viewDidAppear], once: true) {
            if let current = self.newGameViewController {
                current.uiviewController.dismiss(animated: true) { [weak self] in
                    self?.newGameViewController = nil
                    self?.showNewGame(viewController)
                }
            } else {
                self.present(viewController.uiviewController, animated: true) { [weak self] in
                    self?.newGameViewController = viewController
                }
            }
        }
    }

    func closeNewGame() {
        newGameViewController?.uiviewController.dismiss(animated: true, completion: nil)
        newGameViewController = nil
    }

    func showMoreOptions(_ viewController: ViewControllable) {
        confineTo(viewEvents: [.viewDidAppear], once: true) { [weak self] in
            if let current = self?.moreOptionsViewController {
                current.uiviewController.dismiss(animated: true) { [weak self] in
                    self?.moreOptionsViewController = nil
                    self?.showMoreOptions(viewController)
                }
            } else {
                self?.present(viewController.uiviewController, animated: true) { [weak self] in
                    self?.moreOptionsViewController = viewController
                }
            }
        }
    }

    func closeMoreOptions() {
        moreOptionsViewController?.uiviewController.dismiss(animated: true, completion: nil)
        moreOptionsViewController = nil
    }

    func showGameLibrary(_ viewController: ViewControllable) {
        confineTo(viewEvents: [.viewDidAppear], once: true) { [weak self] in
            if let current = self?.gameLibraryViewController {
                current.uiviewController.dismiss(animated: true) { [weak self] in
                    self?.gameLibraryViewController = nil
                    self?.showGameLibrary(viewController)
                }
            } else {
                self?.present(viewController.uiviewController, animated: true) { [weak self] in
                    self?.gameLibraryViewController = viewController
                }
            }
        }
    }

    func closeGameLibrary() {
        gameLibraryViewController?.uiviewController.dismiss(animated: true, completion: nil)
        gameLibraryViewController = nil
    }

    // MARK: - Private

    private let layoutGuide = UILayoutGuide()
    private let buttonStackView = UIStackView()
    private let moreButton = Symbol.Button(symbolName: "ellipsis.circle.fill", pointSize: 27.0)

    private var resumeGameButton: HomeButton?
    private var loadGameButton: HomeButton?

    private var newGameViewController: ViewControllable?
    private var moreOptionsViewController: ViewControllable?
    private var gameLibraryViewController: ViewControllable?

    private func setUp() {
        specializedView.backgroundColor = .backgroundPrimary
        specializedView.addLayoutGuide(layoutGuide)
        let image = UIImage(named: "CardIcon")
        let imageView = UIImageView()
        imageView.tintColor = .contentAccentPrimary
        imageView.image = image

        let newGameButton = HomeButton(title: "New Game")
//        let loadGameButton = HomeButton(title: "Load Game")

        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12.0

        specializedView.addSubview(imageView)
        specializedView.addSubview(buttonStackView)
        specializedView.addSubview(moreButton)

        moreButton.symbolColor = .contentAccentPrimary
        moreButton.highlightedSymbolColor = .contentAccentSecondary
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)

        layoutGuide.snp.makeConstraints { make in
            make
                .center
                .equalToSuperview()
            make
                .leading
                .trailing
                .equalTo(specializedView.safeAreaLayoutGuide)
                .inset(16.0)
        }

        imageView.snp.makeConstraints { make in
            make
                .top
                .equalTo(layoutGuide)
            make.centerX.equalTo(layoutGuide)
            make
                .size
                .equalTo(CGSize(width: 128.0,
                                height: 128.0))
        }

        buttonStackView.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalTo(layoutGuide)
            make
                .top
                .equalTo(imageView.snp.bottom)
                .offset(24.0)
            make
                .bottom
                .equalTo(moreButton.snp.top)
                .offset(-24.0)
        }

        moreButton.snp.makeConstraints { make in
            make
                .bottom
                .equalTo(layoutGuide)
            make
                .centerX
                .equalTo(layoutGuide)
        }

        newGameButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        newGameButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        buttonStackView.insertArrangedSubview(newGameButton, at: 0)

//        loadGameButton.setContentCompressionResistancePriority(.required, for: .horizontal)
//        loadGameButton.addTarget(self, action: #selector(didTapLoad), for: .touchUpInside)
//        buttonStackView.insertArrangedSubview(loadGameButton, at: buttonStackView.arrangedSubviews.count)
    }

    @objc
    private func didTapAdd() {
        listener?.didTapNewGame()
    }

    @objc
    private func didTapResume() {
        listener?.didTapResumeLastGame()
    }

    @objc
    private func didTapLoad() {
        listener?.didTapLoadGame()
    }

    @objc
    private func didTapMore() {
        listener?.didTapMore()
    }
}

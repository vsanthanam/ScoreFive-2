//
//  GameViewController.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/29/20.
//

import Foundation
import ShortRibs
import UIKit

/// @mockable
protocol GameViewControllable: ViewControllable {}

/// @mockable
protocol GamePresentableListener: AnyObject {
    func wantNewRound()
}

final class GameViewController: ScopeViewController, GamePresentable, GameViewControllable, UINavigationBarDelegate {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .lightContent
        case .light, .unspecified:
            return .darkContent
        @unknown default:
            return .darkContent
        }
    }
    
    // MARK: - GamePresentable
    
    weak var listener: GamePresentableListener?
    
    func showNewRound(_ viewController: ViewControllable) {
        if let current = self.newRoundViewController {
            current.uiviewController.dismiss(animated: true) { [weak self] in
                self?.newRoundViewController = nil
                self?.showNewRound(viewController)
            }
        } else {
            self.present(viewController.uiviewController, animated: true) { [weak self] in
                self?.newRoundViewController = viewController
            }
        }
    }
    
    func closeNewRound() {
        newRoundViewController?.uiviewController.dismiss(animated: true, completion: nil)
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
        confineTo(viewEvents: [.viewDidAppear], once: true) { [weak self] in
            self?.gameHeader.apply(names: titles)
        }
    }
    
    func updateTotalScores(_ scores: [String]) {
        confineTo(viewEvents: [.viewDidAppear], once: true) { [weak self] in
            self?.gameFooter.apply(scores: scores)
        }
    }
    
    // MARK: - Private
    
    private let header = UINavigationBar()
    private let bottomSpacer = ScopeView()
    private let gameHeader = GameHeaderView()
    private let gameFooter = GameFooterView()
    private let addRoundButton = AddRoundButton()
    private let scoreCardLayoutGuide = UILayoutGuide()
    
    private var newRoundViewController: ViewControllable?
    private var scoreCardViewController: ScoreCardViewControllable?
    
    private func setUp() {
        let navigationItem = UINavigationItem(title: "Score Card")
        navigationItem.largeTitleDisplayMode = .never
        header.setItems([navigationItem], animated: false)
        header.delegate = self
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundPrimary
        header.standardAppearance = appearance
        specializedView.addSubview(header)
        
        specializedView.addLayoutGuide(scoreCardLayoutGuide)
        
        addRoundButton.addTarget(self, action: #selector(didTapAddRound), for: .touchUpInside)
        specializedView.addSubview(addRoundButton)
        
        bottomSpacer.backgroundColor = .contentAccentPrimary
        specializedView.addSubview(bottomSpacer)
        
        specializedView.addSubview(gameHeader)
        
        specializedView.addSubview(gameFooter)
        
        header.snp.makeConstraints { make in
            make
                .top
                .equalTo(specializedView.safeAreaLayoutGuide)
            make
                .leading
                .trailing
                .equalToSuperview()
        }
        
        gameHeader.snp.makeConstraints { make in
            make
                .top
                .equalTo(header.snp.bottom)
            make
                .leading
                .trailing
                .equalToSuperview()
        }
        
        scoreCardLayoutGuide.snp.makeConstraints { make in
            make
                .leading
                .trailing
                .equalToSuperview()
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
                .equalToSuperview()
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
}
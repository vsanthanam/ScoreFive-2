//
//  FiveInteractor.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/28/20.
//

import Combine
import Foundation
import ScoreKeeping
import ShortRibs
import UIKit

/// @mockable
protocol FivePresentable: FiveViewControllable {
    var listener: FivePresentableListener? { get set }
    func showHome(_ viewController: ViewControllable)
    func showGame(_ viewController: ViewControllable)
}

/// @mockable
protocol FiveListener: AnyObject {}

final class FiveInteractor: PresentableInteractor<FivePresentable>, FiveInteractable, FivePresentableListener {

    // MARK: - Initializers

    init(presenter: FivePresentable,
         mutableActiveGameStream: MutableActiveGameStreaming,
         gameStorageWorker: GameStorageWorking,
         homeBuilder: HomeBuildable,
         gameBuilder: GameBuildable) {
        self.mutableActiveGameStream = mutableActiveGameStream
        self.gameStorageWorker = gameStorageWorker
        self.homeBuilder = homeBuilder
        self.gameBuilder = gameBuilder
        super.init(presenter: presenter)
        presenter.listener = self
    }

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        gameStorageWorker.start(on: self)
        let records = (try? gameStorageWorker.fetchGameRecords()) ?? []
        if records.count == 1,
           let record = records.first,
           record.inProgress {
            mutableActiveGameStream.activateGame(with: record.uniqueIdentifier)
        }
        startUpdatingActiveChild()
    }

    // MARK: - API

    weak var listener: FiveListener?

    // MARK: - HomeListener

    func homeWantToOpenGame(withIdentifier identifier: UUID) {
        mutableActiveGameStream.activateGame(with: identifier)
    }

    // MARK: - GameListener

    func gameWantToResign() {
        mutableActiveGameStream.deactiveateCurrentGame()
    }

    // MARK: - Private

    private let mutableActiveGameStream: MutableActiveGameStreaming
    private let gameStorageWorker: GameStorageWorking
    private let homeBuilder: HomeBuildable
    private let gameBuilder: GameBuildable

    private var activeChild: PresentableInteractable?

    private func startUpdatingActiveChild() {
        mutableActiveGameStream.activeGameIdentifier
            .map { uuid in
                uuid != nil
            }
            .removeDuplicates()
            .sink { isActive in
                if isActive {
                    self.routeToGame()
                } else {
                    self.routeToHome()
                }
            }
            .cancelOnDeactivate(interactor: self)
    }

    private func routeToHome() {
        if let current = activeChild {
            detach(child: current)
        }
        let home = homeBuilder.build(withListener: self)
        attach(child: home)
        presenter.showHome(home.viewControllable)
        activeChild = home
    }

    private func routeToGame() {
        if let current = activeChild {
            detach(child: current)
        }
        let game = gameBuilder.build(withListener: self)
        attach(child: game)
        presenter.showGame(game.viewControllable)
        activeChild = game
    }
}

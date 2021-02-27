//
//  NewRoundBuilder.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/29/20.
//

import Foundation
import NeedleFoundation
import ScoreKeeping
import ShortRibs

protocol NewRoundDependency: Dependency {
    var activeGameStream: ActiveGameStreaming { get }
    var gameStorageProvider: GameStorageProviding { get }
    var userSettingsProvider: UserSettingsProviding { get }
}

class NewRoundComponent: Component<NewRoundDependency> {}

/// @mockable
protocol NewRoundInteractable: PresentableInteractable {}

typealias NewRoundDynamicBuildDependency = (
    listener: NewRoundListener,
    previousValue: Round,
    replacingIndex: Int?
)

/// @mockable
protocol NewRoundBuildable: AnyObject {
    func build(withListener listener: NewRoundListener, round: Round, replacingIndex: Int?) -> PresentableInteractable
}

extension NewRoundBuildable {
    func build(withListener listener: NewRoundListener, round: Round) -> PresentableInteractable {
        build(withListener: listener, round: round, replacingIndex: nil)
    }
}

final class NewRoundBuilder: ComponentizedBuilder<NewRoundComponent, PresentableInteractable, NewRoundDynamicBuildDependency, Void>, NewRoundBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: NewRoundComponent, _ dynamicBuildDependency: NewRoundDynamicBuildDependency) -> PresentableInteractable {
        let (listener, round, replacingIndex) = dynamicBuildDependency
        let viewController = NewRoundViewController(replacing: replacingIndex != nil)
        let interactor = NewRoundInteractor(presenter: viewController,
                                            activeGameStream: component.activeGameStream,
                                            gameStorageProvider: component.gameStorageProvider,
                                            userSettingsProvider: component.userSettingsProvider,
                                            replacingIndex: replacingIndex,
                                            round: round)
        interactor.listener = listener
        return interactor
    }

    // MARK: - NewRoundBuildable

    func build(withListener listener: NewRoundListener, round: Round, replacingIndex: Int?) -> PresentableInteractable {
        build(withDynamicBuildDependency: (listener, round, replacingIndex),
              dynamicComponentDependency: ())
    }

}

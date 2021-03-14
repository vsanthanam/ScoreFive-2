//
//  MoreBuilder.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 2/10/21.
//

import Foundation
import NeedleFoundation
import ShortRibs

protocol MoreOptionsDependency: Dependency {}

class MoreOptionsComponent: Component<MoreOptionsDependency> {}

/// @mockable
protocol MoreOptionsInteractable: PresentableInteractable {}

typealias MoreOptionsDynamicBuildDependency = (
    MoreOptionsListener
)

/// @mockable
protocol MoreOptionsBuildable: AnyObject {
    func build(withListener listener: MoreOptionsListener) -> PresentableInteractable
}

final class MoreOptionsBuilder: ComponentizedBuilder<MoreOptionsComponent, PresentableInteractable, MoreOptionsDynamicBuildDependency, Void>, MoreOptionsBuildable {

    // MARK: - ComponentizedBuilder

    override final func build(with component: MoreOptionsComponent, _ dynamicBuildDependency: MoreOptionsDynamicBuildDependency) -> PresentableInteractable {
        let listener = dynamicBuildDependency
        let viewController = MoreOptionsViewController()
        let interactor = MoreOptionsInteractor(presenter: viewController)
        interactor.listener = listener
        return interactor
    }

    // MARK: - MoreBuildable

    func build(withListener listener: MoreOptionsListener) -> PresentableInteractable {
        build(withDynamicBuildDependency: listener,
              dynamicComponentDependency: ())
    }

}

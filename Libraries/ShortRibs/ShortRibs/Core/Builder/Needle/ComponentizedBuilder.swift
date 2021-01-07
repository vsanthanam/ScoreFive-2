//
//  ComponentizedBuilder.swift
//  ShortRibs
//
//  Created by Varun Santhanam on 12/6/20.
//

import Foundation

open class ComponentizedBuilder<Component, Interactor, DynamicBuildDependency, DynamicComponentDependency>: Buildable {

    // MARK: - Initializers

    public required init(componentBuilder: @escaping ComponentBuilder) {
        self.componentBuilder = componentBuilder
    }

    // MARK: - API

    public typealias ComponentBuilder = (DynamicComponentDependency) -> Component

    open func build(with component: Component, _ dynamicBuildDependency: DynamicBuildDependency) -> Interactor {
        fatalError("Abstract Method Not Implemented!")
    }

    public final func build(withDynamicBuildDependency dynamicBuildDependency: DynamicBuildDependency,
                            dynamicComponentDependency: DynamicComponentDependency) -> Interactor {
        build(withDynamicBuildDependency: dynamicBuildDependency,
              dynamicComponentDependency: dynamicComponentDependency).1
    }

    public final func build(withDynamicBuildDependency dynamicBuildDependency: DynamicBuildDependency,
                            dynamicComponentDependency: DynamicComponentDependency) -> (Component, Interactor) {
        let component = componentBuilder(dynamicComponentDependency)
        let newComponent = component as AnyObject
        assert(lastComponent !== newComponent, "componentBuilder should produce new instances of component when build is invoked")
        lastComponent = newComponent

        return (component, build(with: component, dynamicBuildDependency))
    }

    // MARK: - Private

    private weak var lastComponent: AnyObject?
    private let componentBuilder: ComponentBuilder

}

open class SimpleComponentizedBuilder<Component, Interactor>: ComponentizedBuilder<Component, Interactor, Void, Void> {

    // MARK: - API

    open func build(with component: Component) -> Interactor {
        fatalError("Abstract Method Not Implemented!")
    }

    public final func build() -> Interactor {
        build(withDynamicBuildDependency: (),
              dynamicComponentDependency: ())
    }

    // MARK: - ComponentizedBuilder

    override public final func build(with component: Component, _ dynamicBuildDependency: Void) -> Interactor {
        build(with: component)
    }
}

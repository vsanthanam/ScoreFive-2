//
//  Interactor.swift
//  ShortRibs
//
//  Created by Varun Santhanam on 12/6/20.
//

import Combine
import Foundation

/// A protocol that defines the public interface of an `Interactor` available to other classes
///
/// @mockable
public protocol Interactable: WorkerScope {

    /// Activate the interactor
    /// - Note: You probably shouldn't invoke this method directly.
    ///         It's automatically invoked when the interactor is attached to its parent/
    func activate()

    /// Deactivate the interactor
    /// - Note: You probably shouldn't invoke this method directly.
    ///         It's automatically invoked when the interactor is detached from its parent.
    func deactivate()
}

/// An `Interactor`  is node in the application's state tree.
///
/// An  `Interactor` is activated by its parent, and is responsible for activating its children.
///
/// @mockable
open class Interactor: Interactable {

    // MARK: - Initializers

    /// Initialize an `Interactor`
    public init() {}

    // MARK: - Abstract Methods

    /// Abstract method invoked just after this interactor activates
    /// Override this method to start any business logic specific to this scope.
    open func didBecomeActive() {}

    /// Abstract method invoked just before this interactor deactivates
    /// Override this method to stop any business logic or reset state specific to this scope.
    open func willResignActive() {}

    // MARK: - API

    /// The active children of this interactor..
    /// You can add or remove children using the `attach(interactor:)` and `detach(interactor:)` instance methods
    /// Children are activate when they are attached and deactivated when they are attached.
    public private(set) final var children: [Interactable] = []

    /// Attach a child to the interactor
    /// - Parameter child: The child to attach.
    /// - Note: This method will cause a runtime failure if the provided child has already been attached, or is already active.
    public final func attach(child: Interactable) {
        assert(!child.isActive, "You cannot attach a child that is already active!")
        assert(!(children.contains { $0 === child }), "You cannot attach a child that is already attached!")
        children.append(child)
        child.activate()
    }

    /// Detach an already attached child from the interactor
    /// - Parameter child: The child to detach
    /// - Note: This method will cause a runtime failure if the provided child has already been detached, or has already ben deactivated.
    public final func detach(child: Interactable) {
        assert(child.isActive, "You cannot detach a child that isn't active!")
        guard let index = children.firstIndex(where: { e in e as AnyObject === child as AnyObject }) else {
            assertionFailure("You cannot detach a child that isn't already attached!")
            return
        }
        children.remove(at: index)
    }

    // MARK: - WorkerScope

    public final var isActive: Bool {
        internalIsActive
    }

    public final var isActiveStream: AnyPublisher<Bool, Never> {
        $internalIsActive
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Interactable

    public final func activate() {
        guard !isActive else {
            return
        }
        storage = Set<AnyCancellable>()
        internalIsActive = true
        didBecomeActive()
    }

    public final func deactivate() {
        guard isActive else {
            return
        }
        storage?.forEach { cancellable in cancellable.cancel() }
        storage = nil
        internalIsActive = false
    }

    // MARK: - Private

    @Published
    private var internalIsActive: Bool = false

    private var storage: Set<AnyCancellable>?

    fileprivate func store(cancellable: Cancellable) -> Bool {
        guard storage != nil else {
            return false
        }
        cancellable.store(in: &storage!)
        return true
    }

    // MARK: - Deinit

    deinit {
        if isActive {
            deactivate()
        }
        children.forEach { detach(child: $0) }
    }
}

extension Publisher where Failure == Never {

    public func confine(to interactor: Interactable) -> AnyPublisher<Output, Failure> {
        combineLatest(interactor.isActiveStream) { element, isActive in
            (element, isActive)
        }
        .filter { element, isActive in
            isActive
        }
        .map { element, isActive in
            element
        }
        .eraseToAnyPublisher()
    }

}

extension Cancellable {

    @discardableResult
    public func cancelOnDeactivate(interactor: Interactor) -> Cancellable {
        if !interactor.store(cancellable: self) {
            cancel()
        }
        return self
    }

}

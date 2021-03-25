//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation

public protocol OptionalType {
    associatedtype Wrapped
    var asOptional: Wrapped? { get }
}

/// Implementation of the OptionalType protocol by the Optional type
extension Optional: OptionalType {
    public var asOptional: Wrapped? { self }
}

public extension Publisher where Output: OptionalType {
    func filterNil() -> Publishers.CompactMap<Self, Output.Wrapped> {
        compactMap { input in
            input.asOptional
        }
    }
}

public extension Publisher {
    func toOptional() -> Publishers.Map<Self, Output?> {
        map { $0 }
    }
}

public extension Collection where Element: OptionalType {
    func filterNil() -> [Element.Wrapped] {
        compactMap(\.asOptional)
    }
}

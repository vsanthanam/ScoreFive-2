//
// ScoreFive
// Varun Santhanam
//

import Combine
import Foundation

/// Represent an optional value
///
/// This is needed to restrict our Observable extension to Observable that generate
/// .Next events with Optional payload
protocol OptionalType {
    associatedtype Wrapped
    var asOptional: Wrapped? { get }
}

/// Implementation of the OptionalType protocol by the Optional type
extension Optional: OptionalType {
    var asOptional: Wrapped? { self }
}

extension Publisher where Output: OptionalType {
    func filterNil() -> Publishers.CompactMap<Self, Output.Wrapped> {
        compactMap { input in
            input.asOptional
        }
    }
}

extension Publisher {
    func toOptional() -> Publishers.Map<Self, Output?> {
        map { $0 }
    }
}

extension Collection where Element: OptionalType {
    func filterNil() -> [Element.Wrapped] {
        compactMap { $0.asOptional }
    }
}

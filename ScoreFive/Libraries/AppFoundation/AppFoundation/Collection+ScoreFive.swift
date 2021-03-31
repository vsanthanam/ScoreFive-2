//
// ScoreFive
// Varun Santhanam
//

import Foundation

public extension Collection {

    /// Sort collection using a key path
    /// - Parameters:
    ///   - keyPath: Key path
    ///   - comparator: Comparison func
    /// - Returns: The sorted array
    func sorted<T>(by keyPath: KeyPath<Element, T>, _ comparator: (_ lhs: T, _ rhs: T) -> Bool) -> [Element] {
        sorted { lhs, rhs in
            comparator(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
        }
    }

    /// Sort the collection using a key path
    /// - Parameter keyPath: key path
    /// - Returns: The sorted array
    func sorted<T>(by keyPath: KeyPath<Element, T>) -> [Element] where T: Comparable {
        sorted(by: keyPath, <)
    }
}

extension Array {

    mutating func sort<T>(by keyPath: KeyPath<Element, T>, _ comparator: (_ lhs: T, _ rhs: T) -> Bool) {
        self = sorted(by: keyPath, comparator)
    }

    mutating func sort<T>(by keyPath: KeyPath<Element, T>) where T: Comparable {
        self = sorted(by: keyPath)
    }

}

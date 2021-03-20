//
// ScoreFive
// Varun Santhanam
//

import Foundation

extension Collection {

    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>, _ comparator: (_ lhs: Value, _ rhs: Value) -> Bool) -> [Element] {
        sorted { lhs, rhs in
            comparator(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
        }
    }

    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        sorted(by: keyPath, <)
    }

}

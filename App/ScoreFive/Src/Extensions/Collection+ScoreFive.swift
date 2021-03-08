//
//  Collection+ScoreFive.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 3/7/21.
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

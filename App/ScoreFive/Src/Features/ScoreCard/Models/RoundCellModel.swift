//
//  RoundCellModel.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 3/7/21.
//

import Foundation

struct RoundCellModel: Equatable, Hashable {
    let visibleIndex: String?
    let index: Int
    let scores: [Int?]
    let canRemove: Bool
}

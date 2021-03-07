//
//  GameLibraryCell.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 3/7/21.
//

import Foundation

struct LibraryCellViewModel: Equatable, Hashable {
    let players: [String]
    let date: Date
    let identifier: UUID
}

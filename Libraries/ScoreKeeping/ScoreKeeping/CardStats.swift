//
//  ScoreCardStatistics.swift
//  ScoreKeeping
//
//  Created by Varun Santhanam on 2/26/21.
//

import Foundation

extension ScoreCard {

    /// Average score in this card
    public var averageScore: Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return allScores.average
    }

    /// Average score in this card, excluding zeroes
    public var averageNonZeroScore: Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return allScores.withoutZeroes.average
    }

    /// Average score for a player in this card
    /// - Parameter player: The player
    /// - Returns: The score
    public func averageScore(for player: Player) -> Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return scores(for: player).average
    }

    /// Average score for a player in this card, excluding zeroes
    /// - Parameter player: The player
    /// - Returns: The score
    public func averageNonZeroScore(for player: Player) -> Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return scores(for: player).withoutZeroes.average
    }

    /// Best score in this round, excluding zeros
    public var bestNonZeroScore: Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return allScores.withoutZeroes.min()!
    }

    /// Worst score in this round, excluding 50s
    public var worstNonFiftyScore: Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return allScores.withoutFifties.max()!
    }

    /// Best score for the player, given a player, excluding zeros
    /// - Parameter player: The player
    /// - Returns: The score
    public func bestNonZeroScore(for player: Player) -> Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return scores(for: player).withoutZeroes.min()!
    }

    /// Worst score for the player, given a player, excluding 50s
    /// - Parameter player: The player
    /// - Returns: The score
    public func worstNonFiftyScore(for player: Player) -> Int {
        guard !rounds.isEmpty else {
            fatalError("This game has no scores")
        }
        return scores(for: player).withoutFifties.max()!
    }
}

extension ScoreCard {

    var allScores: [Int] {
        let scores: [Int?] = rounds.reduce([]) { scores, round in
            var newScores = scores
            for id in round.playerIds {
                newScores.append(round.score(for: id))
            }
            return newScores
        }
        return scores.compactMap { $0 }
    }

    func scores(for player: Player) -> [Int] {
        rounds
            .reduce([]) { scores, round in
                var newScores = scores
                newScores.append(round[player.id])
                return newScores
            }
            .compactMap { $0 }
    }
}

extension Array where Element == Int {

    var average: Int {
        let precise = Double(reduce(0, +)) / Double(count)
        return Int(precise.rounded())
    }

    var withoutZeroes: [Int] {
        filter { $0 != 0 }
    }

    var withoutFifties: [Int] {
        filter { $0 != 50 }
    }

}

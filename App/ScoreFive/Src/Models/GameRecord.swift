//
//  Game+CoreDataClass.swift
//  ScoreFive
//
//  Created by Varun Santhanam on 12/28/20.
//
//

import CoreData
import Foundation
import ScoreKeeping
import ShortRibs

/// @mockable
protocol GameRecord: AnyObject {
    var inProgress: Bool { get }
    var uniqueIdentifier: UUID { get }
    var orderedPlayers: [Player] { get }
    var activePlayers: [Player] { get }
    var rankedPlayers: [Player] { get }
    var scoreLimit: Int { get }
    var lastSavedDate: Date { get }
    func getScoreCard() throws -> ScoreCard
    func updateScoreCard(scoreCard: ScoreCard) throws
    func stamp()
}

extension GameRecordMO: GameRecord {

    // MARK: - GameRecord

    var uniqueIdentifier: UUID { rawIdentifier! }

    var orderedPlayers: [Player] {
        orderedPlayerIds!.compactMap(player(for:))
    }

    var activePlayers: [Player] {
        activePlayerIds!.compactMap(player(for:))
    }

    var rankedPlayers: [Player] {
        rankedPlayerIds!.compactMap(player(for:))
    }

    var scoreLimit: Int {
        Int(rawScoreLimit)
    }

    var lastSavedDate: Date {
        rawDate!
    }

    func getScoreCard() throws -> ScoreCard {
        let decoder = JSONDecoder()
        return try decoder.decode(ScoreCard.self, from: scoreCardData!)
    }

    func updateScoreCard(scoreCard: ScoreCard) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(scoreCard)
        scoreCardData = data
        bind(scoreCard)
    }

    func stamp() {
        rawDate = .init()
    }

    // MARK: - Private

    private func bind(_ scoreCard: ScoreCard) {
        inProgress = scoreCard.canAddRounds
        playerNamesMap = scoreCard.orderedPlayers.reduce([:]) { previous, player in
            var dict = previous
            dict![player.uuid] = player.name
            return dict
        }
        rankedPlayerIds = scoreCard.rankedPlayers.map(\.uuid)
        activePlayerIds = scoreCard.orderedActivePlayers.map(\.uuid)
        orderedPlayerIds = scoreCard.orderedPlayers.map(\.uuid)
        rawScoreLimit = Int64(scoreCard.scoreLimit)
    }

    private func player(for id: UUID) -> Player? {
        guard let name = playerNamesMap![id] else {
            return nil
        }
        return .init(name: name, uuid: id)
    }
}

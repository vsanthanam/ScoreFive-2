//
//  ScoreCard.swift
//  ScoreKeeping
//
//  Created by Varun Santhanam on 12/28/20.
//

import Foundation

/// A `ScoreCard` is a struct used to record a game of five.
/// The card is initialized with a score limit and a list of players.
/// Rounds are added to the card until players are eliminated by crossing the score limit
/// The game ends when there is only 1 player left.
public struct ScoreCard: Codable, Equatable, Hashable {

    // MARK: - Initializers
    
    /// Create a `ScoreCard`
    /// - Parameters:
    ///   - scoreLimit: The score limit used to eliminate players. Defaults to 250.
    ///   - orderedPlayers: The players in this game, ordered by who plays first.
    public init(scoreLimit: Int = 250,
                orderedPlayers: [Player]) {
        precondition(orderedPlayers.count >= 2, "There must be at least 2 players in a game")
        precondition(orderedPlayers.count <= 8, "There can only be 8 players in a game")
        precondition(scoreLimit >= 50, "Score limit must be at least 50")
        self.scoreLimit = scoreLimit
        self.orderedPlayers = orderedPlayers
    }
    
    // MARK: - API
    
    /// The score limit used to eliminate players
    public private(set) var scoreLimit: Int
    
    /// All the players in the game, in order of who goes firest
    public let orderedPlayers: [Player]
    
    /// All the players remaining in the game, in order of who goes first
    public var activePlayers: [Player] {
        orderedPlayers
            .filter { player in
                totalScore(for: player) < scoreLimit
            }
    }
    
    /// All the players in the game, from winning to losing
    public var rankedPlayers: [Player] {
        orderedPlayers
            .sorted { lhs, rhs -> Bool in
                totalScore(for: lhs) < totalScore(for: rhs)
            }
    }
    
    /// All the players remaining the game, from winning to losing
    public var activePlayersRanked: [Player] {
        rankedPlayers
            .filter { player in
                totalScore(for: player) < scoreLimit
            }
    }
    
    /// Whether or not the game is in progress and can accept new rounds
    public var canAddRounds: Bool {
        activePlayers.count > 1
    }
    
    /// The number of rounds in this score card
    public var numberOfRounds: Int {
        rounds.count
    }
    
    /// The total score for a player
    /// - Parameter player: The player
    /// - Returns: The total score for the player
    /// - Note: This method produces a run-time failure if the player is not in this game
    public func totalScore(for player: Player) -> Int {
        guard orderedPlayers.contains(player) else {
            fatalError("This score card does not contain this player")
        }
        let uuids = orderedPlayers.map { player in
            player.uuid
        }
        precondition(uuids.contains(player.uuid))
        let applicableRounds = rounds.filter { round in
            round.containsScore(for: player)
        }
        return applicableRounds.reduce(0) { total, round in
            total + (round.score(for: player) ?? 0)
        }
    }
    
    /// Get the round at the specified index
    /// - Parameter index: The specified index
    /// - Returns: The round at that index
    /// - Note: This method produces a run-time failure no such index exists
    public func round(at index: Int) -> Round {
        guard index < rounds.count else {
            fatalError("This game does not contain a round at this index")
        }
        return rounds[index]
    }
    
    /// Whether or not a round can be replaced with a new round
    /// - Parameters:
    ///   - index: The index of the round you want to replace
    ///   - newRound: The new round
    /// - Returns: Whether or not the update is permissable
    /// - Note: You cannot update a round with a new round that would change which players have been eliminated, unless that round is the most recent round.
    public func canReplaceRound(at index: Int, with newRound: Round) -> Bool {
        guard index < rounds.count else {
            return false
        }
        if index == rounds.count - 1 {
            return true
        }
        var copy = self
        let activePlayers = copy.activePlayers
        copy.rounds[index] = newRound
        return activePlayers == copy.activePlayers
    }
    
    /// Remove the round at the specified index
    /// - Parameter index: The index used to remove the round
    /// - Note: this method prodiuces a run-time failure if no such index exists
    public mutating func removeRound(at index: Int) {
        guard index < rounds.count else {
            fatalError("This game does not contain a round at this index")
        }
        rounds.remove(at: index)
        precondition(activePlayers.count >= 1, "Round must leave at least one player standing after being removal")
    }
    
    /// Replace the round at the given index
    /// - Parameters:
    ///   - index: The index to replace
    ///   - newRound: The new round
    /// - Note: This method produes a run-time failure if the index doesn't exist in the score card, or if the desired change is not permissable.
    ///         You can validate a change before making one using `canReplaceRound:`
    public mutating func replaceRound(at index: Int, with newRound: Round) {
        guard canReplaceRound(at: index, with: newRound) else {
            fatalError("Cannot replace round with new round that would change which players have or haven't been eliminated")
        }
        rounds[index] = newRound
    }
    
    /// Update the score limit
    /// - Parameter scoreLimit: The new score limit
    /// - Note: This method produces a run-time failure if this new score limit eliminates any existing players. The new score limit can revive previously eliminated players, however.
    public mutating func updateScoreLimit(_ scoreLimit: Int) {
        fatalError("This method hasn't been implemented yet.")
    }
    
    /// Add a new round
    /// - Parameter round: The new round to add
    /// - Note: This method produces a run-time failure if this round doesn't contain the right players or doesn't contain at least 1 winner and 1 loser.
    public mutating func addRound(_ round: Round) {
        precondition(canAddRounds, "This game cannot accept rounds unless its score limit is increased or existing rounds are removed")
        precondition(round.players == activePlayers, "Round players do not match currently active players")
        let zeros = round.containedScores.map { score in score == 0 }
        precondition(zeros.count > 1, "Round must contain at least 1 winner before being added")
        precondition(zeros.count < round.players.count, "Round must contain 1 loser before being added")
        rounds.append(round)
        precondition(activePlayers.count >= 1, "Round must leave at least one player standing after being added")
    }
    
    // MARK: - Subscript
    
    subscript(player: Player) -> Int {
        totalScore(for: player)
    }
    
    subscript(index: Int) -> Round {
        round(at: index)
    }
    
    // MARK: - Private
    
    private var rounds = [Round]()
}

fileprivate extension Round {
    
    func containsScore(for player: Player) -> Bool {
        score(for: player) != nil
    }
    
    var containedScores: [Int] {
        players
            .map { player -> Int? in
                score(for: player)
            }
            .compactMap { $0 }
    }
}

//
//  Round.swift
//  ScoreKeeping
//
//  Created by Varun Santhanam on 12/28/20.
//

import Foundation

/// A `Round` is a struct that encapsultes a single hand in a game
/// A `Round` cannot contain scores below 0 or above 50, nor can it contain duplicate players
/// It's contents are further validated by the `ScoreCard` it is eventually added to ensure that it is valid for the card at the providwed index
public struct Round: Codable, Equatable, Hashable {

    // MARK: - Initializers
    
    /// An create an empty `Round`
    public init() {
        self.scores = [Player: Int]()
    }
    
    /// Create a `Round` from a collection of players and scores
    /// - Parameter entries: An array of tuples that contain a player and an associated score
    /// - Note: This initializer produces a run-time failure if the provided collection contains invalid scores or duplicate players
    public init(entries: [(Player, Int)]) {
        let players = entries.map { entry in entry.0 }
        precondition(entries.count == Set(players).count, "Entry must not contain duplicate players")
        self.scores = entries.reduce([Player: Int]()) { scores, entry in
            let (player, score) = entry
            precondition(score >= 0, "Entry must not contain scores less than 0")
            precondition(score <= 50, "Entry must not contain score greater than 50")
            var existing = scores
            existing[player] = score
            return existing
        }
    }
    
    /// Create a `Round` from a dictionary of players and scores
    /// - Parameter entries: A dictionary with players and scores
    /// - Note: This initialize produces a run-time failure if the provided collection contains invalid scores.
    public init(entries: [Player: Int]) {
        let aboveZero = entries.values.map { value in value >= 0 }
        let belowFifty = entries.values.map { value in value <= 50 }
        precondition(!aboveZero.contains(false), "Entry must not contain scores less than 0")
        precondition(!belowFifty.contains(false), "Entry must not contain score greater than 50")
        self.init(entries: entries)
    }
    
    /// Create a `Round` from another round
    /// - Parameter Round: The round to copy
    public init(round: Round) {
        self = round
    }
    
    // MARK: - API
    
    /// The players in this round that have a score
    public var players: [Player] {
        .init(scores.keys)
    }
    
    /// Retrieve the score for player stored in this round
    /// - Parameter player: The player to retrieve the score
    /// - Returns: The score fo the player if it exists in this round, or `nil` if no such player exists
    public func score(for player: Player) -> Int? {
        scores[player]
    }
    
    /// Set the score for a player in the round
    /// - Parameters:
    ///   - score: The score to assign to the player
    ///   - player: The player to hold the score
    /// - Note: If the round already contains a score for the player, the previous value is replaced
    /// - Note: This method produces a run-time failure if the provided score is invalid
    public mutating func set(score: Int, for player: Player) {
        precondition(score >= 0, "Score must be greater than 0")
        precondition(score <= 50, "Score must be less than or equal to 50")
        scores[player] = score
    }
    
    /// Remove a score from a player
    /// - Parameter player: The player to remove the score
    public mutating func removeScore(for player: Player) {
        scores.removeValue(forKey: player)
    }
    
    // MARK: - Subscript
    
    /// Subscriptable interface to retrieve, add and remove scores from the round
    public subscript(player: Player) -> Int? {
        get {
            score(for: player)
        }
        
        set {
            if let score = newValue {
                set(score: score, for: player)
            } else {
                removeScore(for: player)
            }
        }
    }
    
    // MARK: - Private
    
    private var scores: [Player: Int]
}

//
//  Player.swift
//  ScoreKeeping
//
//  Created by Varun Santhanam on 12/28/20.
//

import Foundation

/// A player is a struct that uniquely identifies each player in a game while also providing a human-readable name
public struct Player: Codable, Hashable, Equatable, Identifiable {

    // MARK: - Initializers

    /// Create a player
    /// - Parameters:
    ///   - name: The human-readalbe name of the player
    ///   - uuid: The unique identifier of the player
    public init(name: String,
                uuid: UUID) {
        self.name = name
        self.uuid = uuid
    }

    // MARK: - API

    /// The unique identifier of the player
    public let uuid: UUID

    /// The name of the player
    public let name: String

    // MARK: - Identifiable

    public typealias ID = UUID

    public var id: ID {
        uuid
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(uuid)
    }
}

public func == (lhs: Player, rhs: Player) -> Bool {
    lhs.id == rhs.id
}

//
//  Player.swift
//  Hookies
//
//  Created by JinYing on 12/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation

struct Player {
    let playerId: String
    let isCurrentPlayer: Bool
    let playerType: PlayerType
    private(set) var costumeType: CostumeType
    private(set) var botType: BotType?
    private(set) var isHost: Bool

    init?(playerId: String, playerType: PlayerType, costumeType: CostumeType, isCurrentPlayer: Bool, isHost: Bool) {
        if playerType != .human {
            return nil
        }

        self.playerId = playerId
        self.playerType = playerType
        self.costumeType = costumeType
        self.isCurrentPlayer = isCurrentPlayer
        self.isHost = isHost
    }

    init?(playerId: String, playerType: PlayerType, costumeType: CostumeType, botType: BotType) {
        if playerType != .bot {
            return nil
        }

        self.playerId = playerId
        self.playerType = playerType
        self.costumeType = costumeType
        self.botType = botType
        self.isCurrentPlayer = false
        self.isHost = false
    }
}

// MARK: - Hashable

extension Player: Hashable {
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.playerId == rhs.playerId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(playerId)
    }
}

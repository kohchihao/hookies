//
//  HealthSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics

/// A player dies only if he goes too low. Below a fixed horizontal line.

protocol HealthSystemProtocol {
    func isPlayerAlive(for sprite: SpriteComponent) -> Bool
    func respawnPlayer(for sprite: SpriteComponent) -> SpriteComponent
}

class HealthSystem: System, HealthSystemProtocol {

    private let deathHorizontalLine = CGFloat(-1_000)
    private let spawnHorizontalLine = CGFloat(500)

    func isPlayerAlive(for sprite: SpriteComponent) -> Bool {
        if sprite.node.position.y <= deathHorizontalLine {
            return true
        }
        return false
    }

    func respawnPlayer(for sprite: SpriteComponent) -> SpriteComponent {
        sprite.node.position = CGPoint(x: sprite.node.position.x, y: spawnHorizontalLine)
        return sprite
    }
}

// MARK: - Broadcast Update

extension HealthSystem: GenericPlayerEventBroadcast {
    func broadcastUpdate(gameId: String, playerId: String, player: PlayerEntity) {
        broadcastUpdate(gameId: gameId, playerId: playerId, player: player, eventType: .playerDied)
    }
}

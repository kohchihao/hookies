//
//  CannonSystem.swift
//  Hookies
//
//  Created by JinYing on 31/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

protocol CannonSystemProtocol {
    func launch(player: SpriteComponent, with velocity: CGVector)
}

class CannonSystem: System, CannonSystemProtocol {
    private let cannon: SpriteComponent

    init(cannon: SpriteComponent) {
        self.cannon = cannon
    }

    func launch(player: SpriteComponent, with velocity: CGVector) {
        player.node.physicsBody?.isDynamic = true
        player.node.physicsBody?.applyImpulse(velocity)
    }

    func launch(otherPlayer: SpriteComponent, with velocity: CGVector) {
        otherPlayer.node.physicsBody?.isDynamic = true
        otherPlayer.node.physicsBody?.velocity = velocity
    }
}

// MARK: - Broadcast Update

extension CannonSystem: GenericPlayerEventBroadcast {
    func broadcastUpdate(gameId: String, playerId: String, player: SpriteComponent) {
        broadcastUpdate(gameId: gameId, playerId: playerId, player: player, eventType: .shotFromCannon)
    }
}

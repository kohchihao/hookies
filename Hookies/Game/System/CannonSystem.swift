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
}

// MARK: - Broadcast Update

extension CannonSystem {
    func broadcastUpdate(gameId: String, playerId: String, player: PlayerEntity) {
        guard let genericPlayerEventData = createPlayerEventData(from: playerId, and: player) else {
            return
        }

        API.shared.gameplay.boardcastGenericPlayerEvent(playerEvent: genericPlayerEventData)
    }

    private func createPlayerEventData(from playerId: String, and player: PlayerEntity) -> GenericPlayerEventData? {
        guard let sprite = player.getSpriteComponent() else {
            return nil
        }

        let position = Vector(point: sprite.node.position)
        let velocity = Vector(vector: sprite.node.physicsBody?.velocity)

        return GenericPlayerEventData(
            playerId: playerId,
            position: position,
            velocity: velocity,
            type: .shotFromCannon
        )
    }
}

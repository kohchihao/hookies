//
//  DeadlockSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 29/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

/// Checks if the player is stuck in a deadlock or not.

protocol DeadlockSystemProtocol {
    func checkIfStuck() -> Bool
}

class DeadlockSystem: System, DeadlockSystemProtocol {

    private var sprite: SpriteComponent
    private var isStuck = false
    private var contactedPlatforms: [SKSpriteNode: Int] = [:]
    private let highestMinimumHorizontalVelocity: CGFloat = 0.5
    private let lowestMinimumHorizontalVelocity: CGFloat = -0.5
    private let maximumTouches = 10

    init(sprite: SpriteComponent) {
        self.sprite = sprite
    }

    func checkIfStuck() -> Bool {
        guard let physicsBody = sprite.node.physicsBody else {
            return false
        }

        let isVelocityNearlyZero = isVelocityNearlyZeroDeadlock(physicsBody)
        let isInfiniteBouncing = isInfiniteBouncingDeadlock(physicsBody)

       return isVelocityNearlyZero || isInfiniteBouncing
    }

    /// Checks for velocity is nearly 0.
    private func isVelocityNearlyZeroDeadlock(_ physicsBody: SKPhysicsBody) -> Bool {
        let playerHorizontalVelocity = physicsBody.velocity.dx
        let isVelocityNearlyZero = playerHorizontalVelocity < highestMinimumHorizontalVelocity
            && playerHorizontalVelocity > lowestMinimumHorizontalVelocity
        return isVelocityNearlyZero
    }

    /// Checks for infinite bouncing.
    private func isInfiniteBouncingDeadlock(_ physicsBody: SKPhysicsBody) -> Bool {
        let contactedPhysicsBodies = physicsBody.allContactedBodies()
        for contactedBody in contactedPhysicsBodies {
            guard let spriteNode = contactedBody.node as? SKSpriteNode else {
                return false
            }
            if spriteNode.name == GameObjectType.platform.rawValue
                || spriteNode.name == GameObjectType.platformMovable.rawValue {
                if let touchCount = contactedPlatforms[spriteNode] {
                    contactedPlatforms[spriteNode] = touchCount + 1
                    if contactedPlatforms[spriteNode] == maximumTouches {
                        contactedPlatforms.removeAll()
                        return true
                    }
                } else {
                    contactedPlatforms[spriteNode] = 1
                }
            }
        }
        return false
    }
}

extension DeadlockSystem {
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
            type: .jumpAction
        )
    }
}

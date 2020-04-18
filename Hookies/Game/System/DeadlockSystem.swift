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
    func resolveDeadlock()
    func resolveDeadlock(for sprite: SpriteComponent, at position: CGPoint, with velocity: CGVector)
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedJumpAction(_:)),
            name: .receivedJumpAction,
            object: nil)
    }

    func checkIfStuck() -> Bool {
        guard let physicsBody = sprite.node.physicsBody else {
            return false
        }

        let isVelocityNearlyZero = isVelocityNearlyZeroDeadlock(physicsBody)
        let isInfiniteBouncing = isInfiniteBouncingDeadlock(physicsBody)

       return isVelocityNearlyZero || isInfiniteBouncing
    }

    /// Resolve deadlock for single player
    func resolveDeadlock() {
        guard let velocity = sprite.node.physicsBody?.velocity else {
            return
        }

        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: .jumpAction)
        broadcast(genericSystemEvent)
        return resolveDeadlock(for: sprite, at: sprite.node.position, with: velocity)
    }

    /// Resolve deadlock for multi player
    internal func resolveDeadlock(for sprite: SpriteComponent, at position: CGPoint, with velocity: CGVector) {
        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        sprite.node.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 500))
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

    /// Broadcast
    private func broadcast(_ genericSystemEvent: GenericSystemEvent) {
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }
}

// MARK: - Broadcast Update
// TODO: REMOVE

extension DeadlockSystem: GenericPlayerEventBroadcast {
    func broadcastUpdate(gameId: String, playerId: String, player: SpriteComponent) {
        broadcastUpdate(gameId: gameId, playerId: playerId, player: player, eventType: .jumpAction)
    }
}

// MARK: - Networking

extension DeadlockSystem {

    @objc private func receivedJumpAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            guard let velocity = sprite.node.physicsBody?.velocity else {
                return
            }
            resolveDeadlock(for: sprite, at: sprite.node.position, with: velocity)
        }
    }
}

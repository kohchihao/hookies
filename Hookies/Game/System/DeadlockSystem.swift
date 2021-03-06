//
//  DeadlockSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 29/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

/// Deadlock System helps to check if the player is stuck in a deadlock or not and respawn the sprite.

protocol DeadlockSystemProtocol {
    func checkIfStuck() -> Bool
    func resolveDeadlock()
}

class DeadlockSystem: System, DeadlockSystemProtocol {

    private var sprite: SpriteComponent
    private var hook: HookComponent
    private var isStuck = false
    private var contactedPlatforms: [SKSpriteNode: Int] = [:]
    private let highestMinimumHorizontalVelocity: CGFloat = 0.5
    private let lowestMinimumHorizontalVelocity: CGFloat = -0.5
    private let maximumTouches = 10

    init(sprite: SpriteComponent, hook: HookComponent) {
        self.sprite = sprite
        self.hook = hook
        registerNotificationObservers()
    }

    /// Checks if the player's sprite is stuck.
    func checkIfStuck() -> Bool {
        guard let physicsBody = sprite.node.physicsBody else {
            return false
        }

        guard hook.hookTo == nil else {
            return false
        }

        let isVelocityNearlyZero = isVelocityNearlyZeroDeadlock(physicsBody)
        let isInfiniteBouncing = isInfiniteBouncingDeadlock(physicsBody)

       return isVelocityNearlyZero || isInfiniteBouncing
    }

    /// Resolve deadlock for single player.
    func resolveDeadlock() {
        guard let velocity = sprite.node.physicsBody?.velocity else {
            return
        }

        broadcast(with: sprite)
        return resolveDeadlock(for: sprite, at: sprite.node.position, with: velocity)
    }

    /// Resolve deadlock for multi player
    /// - Parameters:
    ///   - sprite: The sprite to resolve deadlock for
    ///   - position: The position of the sprite
    ///   - velocity: The velocity of the sprite
    private func resolveDeadlock(for sprite: SpriteComponent, at position: CGPoint, with velocity: CGVector) {
        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        sprite.node.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 500))
    }

    /// Checks for velocity is nearly 0.
    /// - Parameters:
    ///   - physicsBody: The physicsBody of the sprite
    private func isVelocityNearlyZeroDeadlock(_ physicsBody: SKPhysicsBody) -> Bool {
        let playerHorizontalVelocity = physicsBody.velocity.dx
        let isVelocityNearlyZero = playerHorizontalVelocity < highestMinimumHorizontalVelocity
            && playerHorizontalVelocity > lowestMinimumHorizontalVelocity
        return isVelocityNearlyZero
    }

    /// Checks for infinite bouncing.
    /// - Parameters:
    ///   - physicsBody: The physicsBody of the sprite
    private func isInfiniteBouncingDeadlock(_ physicsBody: SKPhysicsBody) -> Bool {
        let contactedPhysicsBodies = physicsBody.allContactedBodies()
        for contactedBody in contactedPhysicsBodies {
            guard let spriteNode = contactedBody.node as? SKSpriteNode else {
                return false
            }
            // Checks if the contacted bodies is a moving platform or stationary platform
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

// MARK: - Networking

extension DeadlockSystem {
    private func registerNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedJumpAction(_:)),
            name: .receivedJumpAction,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(broadcastUnregisterObserver(_:)),
            name: .broadcastUnregisterObserver,
            object: nil)
    }

    /// Broadcast to Notification Center.
    private func broadcast(with sprite: SpriteComponent) {
        let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: .jumpAction)
        NotificationCenter.default.post(
            name: .broadcastGenericPlayerAction,
            object: self,
            userInfo: ["data": genericSystemEvent])
    }

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

    @objc private func broadcastUnregisterObserver(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
}

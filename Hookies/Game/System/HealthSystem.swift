//
//  HealthSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit

/// A player dies only if he
/// Death condition
///  - Below fixed horizontal line
///  - Above fixed horizontal line
///  - Behind starting line

protocol HealthSystemProtocol {
    func isPlayerAlive(for sprite: SpriteComponent) -> Bool
    func isPlayerAlive(for position: CGPoint) -> Bool
    func respawnPlayer(for sprite: SpriteComponent) -> SpriteComponent
    func respawnPlayerToClosestPlatform(for sprite: SpriteComponent) -> SpriteComponent?
}

class HealthSystem: System, HealthSystemProtocol {

    private let deathLowerHorizontalLine = CGFloat(-500)
    private let spawnHorizontalLine = CGFloat(200)
    private let deathUpperHorizontalLine = CGFloat(500)

    private var platforms: [SpriteComponent]
    private var startLine: SpriteComponent

    init(platforms: [SpriteComponent], startLine: SpriteComponent) {
        self.platforms = platforms
        self.startLine = startLine
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedRespawnAction(_:)),
            name: .receivedRespawnAction,
            object: nil)
    }

    func isPlayerAlive(for sprite: SpriteComponent) -> Bool {
        return self.isPlayerAlive(for: sprite.node.position)
    }

    func isPlayerAlive(for position: CGPoint) -> Bool {
        if position.y <= deathLowerHorizontalLine
            || position.y >= deathUpperHorizontalLine
            || position.x < startLine.node.position.x {
            return false
        }
        return true
    }

    /// Respawn single player
    func respawnPlayer(for sprite: SpriteComponent) -> SpriteComponent {
        if !isPlayerAlive(for: sprite) {
            let genericSystemEvent = GenericSystemEvent(sprite: sprite, eventType: .playerDied)
            broadcast(genericSystemEvent)
            return self.respawnPlayer(for: sprite, at: sprite.node.position)
        }
        return sprite
    }

    /// Respawn multiplayer
    private func respawnPlayer(for sprite: SpriteComponent, at position: CGPoint) -> SpriteComponent {
        if !isPlayerAlive(for: position) {
            sprite.node.position = CGPoint(x: position.x, y: spawnHorizontalLine)
            sprite.node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            sprite.node.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 0))
        }

        return sprite
    }

    func respawnPlayerToClosestPlatform(for sprite: SpriteComponent) -> SpriteComponent? {
        guard let closestPlatform = findClosestNonMovingPlatform(to: sprite.node.position),
            !isPlayerAlive(for: sprite)
            else {
            return nil
        }

        sprite.node.position = CGPoint(
            x: closestPlatform.node.position.x,
            y: closestPlatform.node.position.y + 50)
        sprite.node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        sprite.node.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 0))
        return sprite
    }

    private func findClosestNonMovingPlatform(to position: CGPoint) -> SpriteComponent? {
        var closestDistance = Double.greatestFiniteMagnitude
        let otherEntityPosition = Vector(point: position)
        var platformSpriteComponent: SpriteComponent?
        for platform in platforms {
            let platformPositionVector = Vector(point: platform.node.position)
            let distance = platformPositionVector.distance(to: otherEntityPosition)
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                platformSpriteComponent = platform
            }
        }

        return platformSpriteComponent
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
extension HealthSystem: GenericPlayerEventBroadcast {
    func broadcastUpdate(gameId: String, playerId: String, player: SpriteComponent) {
        broadcastUpdate(gameId: gameId, playerId: playerId, player: player, eventType: .playerDied)
    }
}

// MARK: - Networking
extension HealthSystem {
    @objc private func receivedRespawnAction(_ notification: Notification) {
        if let data = notification.userInfo as? [String: GenericSystemEvent] {
            guard let genericSystemEvent = data["data"] else {
                return
            }

            let sprite = genericSystemEvent.sprite
            _ = respawnPlayer(for: sprite, at: sprite.node.position)
        }
    }
}

//
//  HealthSystem.swift
//  Hookies
//
//  Created by Marcus Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import SpriteKit
/// A player dies only if he goes too low. Below a fixed horizontal line.

protocol HealthSystemProtocol {
    func isPlayerAlive(for sprite: SpriteComponent) -> Bool
    func respawnPlayer(for sprite: SpriteComponent) -> SpriteComponent
    func respawnPlayer(for sprite: SpriteComponent, at position: CGPoint) -> SpriteComponent
}

class HealthSystem: System, HealthSystemProtocol {

    private let deathHorizontalLine = CGFloat(-500)
    private let spawnHorizontalLine = CGFloat(200)

    private var platforms: [SpriteComponent]

    init(platforms: [SpriteComponent]) {
        self.platforms = platforms
    }

    func isPlayerAlive(for sprite: SpriteComponent) -> Bool {
        if sprite.node.position.y <= deathHorizontalLine {
            return false
        }
        return true
    }

    func respawnPlayer(for sprite: SpriteComponent) -> SpriteComponent {
        return self.respawnPlayer(for: sprite, at: sprite.node.position)
    }

    func respawnPlayer(for sprite: SpriteComponent, at position: CGPoint) -> SpriteComponent {
        sprite.node.position = CGPoint(x: position.x, y: spawnHorizontalLine)
        sprite.node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        sprite.node.physicsBody?.applyImpulse(CGVector(dx: 500, dy: 0))
        return sprite
    }

    func respawnPlayerToClosestPlatform(for sprite: SpriteComponent) -> SpriteComponent? {
        guard let closestPlatform = findClosestNonMovingPlatform(to: sprite.node.position) else {
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
}

// MARK: - Broadcast Update

extension HealthSystem: GenericPlayerEventBroadcast {
    func broadcastUpdate(gameId: String, playerId: String, player: SpriteComponent) {
        broadcastUpdate(gameId: gameId, playerId: playerId, player: player, eventType: .playerDied)
    }
}

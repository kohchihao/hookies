//
//  PowerupSystemTests.swift
//  HookiesTests
//
//  Created by Jun Wei Koh on 25/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
import Foundation
import SpriteKit
@testable import Hookies

class PowerupSystemTests: XCTestCase {
    var scene = SKScene(size: CGSize(width: 4000, height: 4000))
    var sprite1 = SKSpriteNode(texture: SKTexture(imageNamed: "chest"))
    var sprite2 = SKSpriteNode(texture: SKTexture(imageNamed: "chest"))

    var player1Entity = PlayerEntity()
    var player2Entity = PlayerEntity()
    var shieldPowerupEntity = PowerupEntity.create(for: .shield)
    var stealPowerupEntity = PowerupEntity.create(for: .stealPowerup)
    var netTrapPowerupEntity = PowerupEntity.create(for: .netTrap)

    var player1Sprite: SpriteComponent {
        return player1Entity.get(SpriteComponent.self)!
    }
    var player2Sprite: SpriteComponent {
        return player2Entity.get(SpriteComponent.self)!
    }
    var shieldPowerupComponent: PowerupComponent {
        return shieldPowerupEntity.get(PowerupComponent.self)!
    }
    var stealPowerupComponent: PowerupComponent {
        return stealPowerupEntity.get(PowerupComponent.self)!
    }
    var netTrapPowerupComponent: PowerupComponent {
        return netTrapPowerupEntity.get(PowerupComponent.self)!
    }

    var powerupSystem: PowerupSystem!

    override func setUp() {
        super.setUp()
        powerupSystem = PowerupSystem()

        powerupSystem.addCollectable(powerup: shieldPowerupComponent)
        powerupSystem.addCollectable(powerup: stealPowerupComponent)
        XCTAssertEqual(powerupSystem.collectablePowerups.count, 2)

        powerupSystem.add(player: player1Sprite)
        powerupSystem.add(player: player2Sprite)
        XCTAssertEqual(powerupSystem.players.count, 2)

        sprite1.position = CGPoint(x: 500, y: 500)
        sprite2.position = CGPoint(x: 0, y: 0)
        shieldPowerupEntity.get(SpriteComponent.self)?.node = sprite1
        stealPowerupEntity.get(SpriteComponent.self)?.node = sprite2
    }

    func testCollectionOfPowerup() {
        let shieldSprite = shieldPowerupEntity.get(SpriteComponent.self)!.node
        powerupSystem.collect(powerupNode: shieldSprite, by: player1Sprite)
        XCTAssertEqual(powerupSystem.collectablePowerups.count, 1)

        // Collecting non-existent powerup should do nothing
        powerupSystem.collect(powerupNode: shieldSprite, by: player1Sprite)
        XCTAssertEqual(powerupSystem.collectablePowerups.count, 1)

        // PowerupEntity should have its SpriteEntity removed since it is not
        // on the map
        XCTAssertNil(shieldPowerupEntity.get(SpriteComponent.self))
    }

    func testRemovePowerupFromPlayer() {
        let shieldSprite = shieldPowerupEntity.get(SpriteComponent.self)!.node
        powerupSystem.collect(powerupNode: shieldSprite, by: player1Sprite)
        XCTAssertEqual(powerupSystem.collectablePowerups.count, 1)

        powerupSystem.removePowerup(from: player1Sprite)
        XCTAssertEqual(powerupSystem.ownedPowerups[player1Sprite], [])

        // Removing empty array should do nothing
        powerupSystem.removePowerup(from: player1Sprite)
        XCTAssertEqual(powerupSystem.ownedPowerups[player1Sprite], [])
    }
}

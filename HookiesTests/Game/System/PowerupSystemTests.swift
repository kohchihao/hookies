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

    var player1Entity = PlayerEntity()
    var player2Entity = PlayerEntity()
    var shieldPowerupEntity = PowerupEntity(for: .shield)
    var stealPowerupEntity = PowerupEntity(for: .stealPowerup)
    var netTrapPowerupEntity = PowerupEntity(for: .netTrap)

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

        powerupSystem.add(powerup: shieldPowerupComponent)
        powerupSystem.add(powerup: stealPowerupComponent)
        XCTAssertEqual(powerupSystem.powerups.count, 2)

        powerupSystem.add(player: player1Sprite)
        powerupSystem.add(player: player2Sprite)
        XCTAssertEqual(powerupSystem.players.count, 2)
    }

    func testCollectionOfPowerup() {
        powerupSystem.collectAndBroadcast(powerupComponent: shieldPowerupComponent,
                                          by: player1Sprite)
        XCTAssertEqual(powerupSystem.powerups.count, 1)

        // Collecting non-existent powerup should do nothing
        powerupSystem.collectAndBroadcast(powerupComponent: shieldPowerupComponent,
                                          by: player1Sprite)
        XCTAssertEqual(powerupSystem.powerups.count, 1)

        // Player should be assigned that powerup
        XCTAssertEqual(powerupSystem.ownedPowerups[player1Sprite]!,
                       [shieldPowerupComponent])

        // PowerupEntity should have its SpriteEntity removed since it is not
        // on the map
        XCTAssertNil(shieldPowerupEntity.get(SpriteComponent.self))
    }

    func testRemovePowerupFromPlayer() {
        powerupSystem.collectAndBroadcast(powerupComponent: shieldPowerupComponent,
                                          by: player1Sprite)
        XCTAssertEqual(powerupSystem.powerups.count, 1)

        powerupSystem.removePowerup(from: player1Sprite)
        XCTAssertEqual(powerupSystem.ownedPowerups[player1Sprite], [])

        // Removing empty array should do nothing
        powerupSystem.removePowerup(from: player1Sprite)
        XCTAssertEqual(powerupSystem.ownedPowerups[player1Sprite], [])
    }

    func testActivatePowerup() {
        // Activating a non owned powerup should do nothing
        powerupSystem.activateAndBroadcast(powerupType: .netTrap,
                                           for: player1Sprite)
        XCTAssertTrue(powerupSystem.activatedPowerups[player1Sprite]!.isEmpty)

        // Activating a powerup
        powerupSystem.collectAndBroadcast(powerupComponent: shieldPowerupComponent,
                                          by: player1Sprite)
        powerupSystem.activateAndBroadcast(powerupType: .shield, for: player1Sprite)
        XCTAssertEqual(powerupSystem.activatedPowerups[player1Sprite]!,
                       [shieldPowerupComponent])
    }

    func testActivateShieldPowerup() {
        powerupSystem.collectAndBroadcast(powerupComponent: shieldPowerupComponent,
                                          by: player1Sprite)
        powerupSystem.activateAndBroadcast(powerupType: .shield, for: player1Sprite)
        XCTAssertTrue(shieldPowerupComponent.parent
            .get(PowerupEffectComponent.self) is ShieldEffectComponent)
    }

    func testActivatingNetTrapPowerup() {
        powerupSystem.add(powerup: netTrapPowerupComponent)
        powerupSystem.collectAndBroadcast(powerupComponent: netTrapPowerupComponent,
                                          by: player1Sprite)
        powerupSystem.activateAndBroadcast(powerupType: .netTrap, for: player1Sprite)
        XCTAssertEqual(powerupSystem.netTraps.first!,
                       netTrapPowerupComponent.parent.get(SpriteComponent.self)!)

        let positionOfTrap = CGPoint(x: 0, y: 0)
        // Since net trap will affect the movement
        XCTAssertNotNil(netTrapPowerupEntity.get(MovementEffectComponent.self))
        let movementEffect = netTrapPowerupEntity.get(MovementEffectComponent.self)!
        XCTAssertTrue(movementEffect.stopMovement)
        XCTAssertEqual(movementEffect.from, positionOfTrap)
        XCTAssertEqual(movementEffect.to, positionOfTrap)
    }
}

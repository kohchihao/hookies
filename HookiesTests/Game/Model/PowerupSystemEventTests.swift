//
//  PowerupSystemEventTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
class PowerupSystemEventTests: XCTestCase {

    var powerupSystemEvent: PowerupSystemEvent!

    var playerSprite: SpriteComponent!
    var playerEntity: PlayerEntity!
    var spriteSystem: SpriteSystem!

    override func setUp() {
        super.setUp()
        spriteSystem = SpriteSystem()
        playerEntity = PlayerEntity()
        playerSprite = SpriteComponent(parent: playerEntity)
        _ = spriteSystem.set(sprite: playerSprite, of: .player1, with: "Pink_Monster", at: CGPoint(x: 10, y: 20))
    }
    override func tearDown() {
        powerupSystemEvent = nil
        super.tearDown()
    }

    func testInitializer_powerupPosition_nil() {
        powerupSystemEvent = PowerupSystemEvent(
            sprite: playerSprite,
            powerupEventType: .activate,
            powerupType: .cutRope)
        XCTAssertNotNil(powerupSystemEvent.sprite)
        XCTAssertNotNil(powerupSystemEvent.powerupEventType)
        XCTAssertNotNil(powerupSystemEvent.powerupType)
        XCTAssertNotNil(powerupSystemEvent.powerupPos)
        XCTAssertEqual(powerupSystemEvent.powerupPos, Vector(x: 10, y: 20))
    }

    func testInitializer_powerupPosition_NotNil() {
        powerupSystemEvent = PowerupSystemEvent(
            sprite: playerSprite,
            powerupEventType: .activate,
            powerupType: .cutRope,
            powerupPos: Vector(x: 20, y: 20))
        XCTAssertNotNil(powerupSystemEvent.sprite)
        XCTAssertNotNil(powerupSystemEvent.powerupEventType)
        XCTAssertNotNil(powerupSystemEvent.powerupType)
        XCTAssertNotNil(powerupSystemEvent.powerupPos)
        XCTAssertEqual(powerupSystemEvent.powerupPos, Vector(x: 20, y: 20))
    }

}

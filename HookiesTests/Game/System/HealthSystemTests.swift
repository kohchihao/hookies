//
//  HealthSystemTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
import SpriteKit
class HealthSystemTests: XCTestCase {

    var healthSystem: HealthSystem!
    var platforms: [SpriteComponent]!
    var spriteSystem: SpriteSystem!

    var platformNode: SKSpriteNode!
    var platformEntity: PlatformEntity!
    var playformSprite: SpriteComponent!

    var playerSprite: SpriteComponent!
    var playerEntity: PlayerEntity!

    override func setUp() {
        super.setUp()
        spriteSystem = SpriteSystem()
        platformEntity = PlatformEntity()
        playformSprite = SpriteComponent(parent: platformEntity)
        platformNode = SKSpriteNode()
        platformNode.position = CGPoint(x: 10, y: 10)
        _ = spriteSystem.set(sprite: playformSprite, to: platformNode)
        platforms = [playformSprite]

        playerEntity = PlayerEntity()
        playerSprite = SpriteComponent(parent: playerEntity)
        _ = spriteSystem.set(sprite: playerSprite, of: .player1, with: "Pink_Monster", at: CGPoint(x: 10, y: 20))

        healthSystem = HealthSystem(platforms: platforms)
    }

    override func tearDown() {
        healthSystem = nil
        platforms = nil
        spriteSystem = nil

        platformNode = nil
        platformEntity = nil
        playformSprite = nil

        playerSprite = nil
        playerEntity = nil
        super.tearDown()
    }

    func testIsPlayerAlive_playerIsAlive() {

    }

    func testIsPlayerAlive_playerIsDead() {

    }

    func testRespawnPlayer_playerIsDead() {

    }

    func testRespawnPlayer_playerIsAlive() {

    }

    func testRespawnPlayerWithPosition_playerIsDead() {

    }

    func testRespawnPlayerWithPosition_playerIsAlive() {

    }

    func testRespawnPlayerToClosestPlatform_playerIsDead() {

    }

    func testRespawnPlayerToClosestPlatform_playerIsAlive() {

    }
}

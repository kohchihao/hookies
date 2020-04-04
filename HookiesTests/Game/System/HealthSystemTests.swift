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
    var platformSprite: SpriteComponent!

    var playerSprite: SpriteComponent!
    var playerEntity: PlayerEntity!

    override func setUp() {
        super.setUp()
        spriteSystem = SpriteSystem()
        platformEntity = PlatformEntity()
        platformSprite = SpriteComponent(parent: platformEntity)
        platformNode = SKSpriteNode()
        platformNode.position = CGPoint(x: 10, y: 10)
        _ = spriteSystem.set(sprite: platformSprite, to: platformNode)
        platforms = [platformSprite]

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
        platformSprite = nil

        playerSprite = nil
        playerEntity = nil
        super.tearDown()
    }

    func testIsPlayerAlive_playerIsAlive() {
        let playerIsAlive = healthSystem.isPlayerAlive(for: playerSprite)
        XCTAssertTrue(playerIsAlive)
    }

    func testIsPlayerAlive_playerIsDead() {
        playerSprite.node.position = CGPoint(x: 1000, y: -500)
        let playerIsAlive = healthSystem.isPlayerAlive(for: playerSprite)
        XCTAssertFalse(playerIsAlive)
    }

    func testRespawnPlayer_playerIsDead() {
        playerSprite.node.position = CGPoint(x: 1000, y: -500)
        _ = healthSystem.respawnPlayer(for: playerSprite)
        XCTAssertEqual(playerSprite.node.position, CGPoint(x: 1000, y: 200))
    }

    func testRespawnPlayer_playerIsAlive() {
        _ = healthSystem.respawnPlayer(for: playerSprite)
        XCTAssertEqual(playerSprite.node.position, CGPoint(x: 10, y: 20))
    }

    func testRespawnPlayerWithPosition_playerIsDead() {
        let pos = CGPoint(x: 1000, y: -500)
        _ = healthSystem.respawnPlayer(for: playerSprite, at: pos)
        XCTAssertEqual(playerSprite.node.position, CGPoint(x: 1000, y: 200))
    }

    func testRespawnPlayerWithPosition_playerIsAlive() {
        let pos = CGPoint(x: 1000, y: -400)
        _ = healthSystem.respawnPlayer(for: playerSprite, at: pos)
        XCTAssertEqual(playerSprite.node.position, CGPoint(x: 10, y: 20))
    }

    func testRespawnPlayerToClosestPlatform_playerIsDead() {
        playerSprite.node.position = CGPoint(x: 1000, y: -500)
        _ = healthSystem.respawnPlayerToClosestPlatform(for: playerSprite)
        XCTAssertEqual(playerSprite.node.position, CGPoint(x: 10, y: 60))
    }

    func testRespawnPlayerToClosestPlatform_playerIsAlive() {
        _ = healthSystem.respawnPlayerToClosestPlatform(for: playerSprite)
        XCTAssertEqual(playerSprite.node.position, CGPoint(x: 10, y: 20))
    }
}

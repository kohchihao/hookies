//
//  DeadlockSystemTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
import SpriteKit
class DeadlockSystemTests: XCTestCase {

    var deadlockSystem: DeadlockSystem!
    var spriteSystem: SpriteSystem!

    var playerSprite: SpriteComponent!
    var playerEntity: PlayerEntity!

    override func setUp() {
        super.setUp()
        spriteSystem = SpriteSystem()
        playerEntity = PlayerEntity()
        playerSprite = SpriteComponent(parent: playerEntity)
        _ = spriteSystem.set(sprite: playerSprite, of: .player1, with: "Pink_Monster", at: CGPoint(x: 10, y: 20))
        _ = spriteSystem.setPhysicsBody(to: playerSprite, of: .player1)
        deadlockSystem = DeadlockSystem(sprite: playerSprite)
    }

    override func tearDown() {
        deadlockSystem = nil
        spriteSystem = nil

        playerSprite = nil
        playerEntity = nil
        super.tearDown()
    }

    func testCheckIfStuck_playerStuck_velocityNearZero() {
        playerSprite.node.physicsBody?.velocity = CGVector(dx: 0.2, dy: 100)
        let isStuck = deadlockSystem.checkIfStuck()
        XCTAssertTrue(isStuck)
    }

    func testCheckIfStuck_playerNotStuck() {
        playerSprite.node.physicsBody?.velocity = CGVector(dx: 0.7, dy: 100)
        let isStuck = deadlockSystem.checkIfStuck()
        XCTAssertFalse(isStuck)
    }

    func testResolveDeadlock() {
        playerSprite.node.physicsBody?.velocity = CGVector(dx: 0.2, dy: 100)
        deadlockSystem.resolveDeadlock()
        XCTAssertNotEqual(CGVector(dx: 0.2, dy: 100), playerSprite.node.physicsBody?.velocity)
    }

    func testResolveDeadlockWithPosition() {
        playerSprite.node.physicsBody?.velocity = CGVector(dx: 0.2, dy: 100)
        deadlockSystem.resolveDeadlock(
            for: playerSprite,
            at: playerSprite.node.position,
            with: playerSprite.node.physicsBody!.velocity)
        XCTAssertNotEqual(CGVector(dx: 0.2, dy: 100), playerSprite.node.physicsBody?.velocity)
    }
}

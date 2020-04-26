//
//  CannonSystemTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
import SpriteKit

class CannonSystemTests: XCTestCase {

    var cannonSystem: CannonSystem!
    var cannonEntity: CannonEntity!
    var cannonNode: SKSpriteNode!
    var spriteSystem: SpriteSystem!

    var playerSprite: SpriteComponent!
    var playerEntity: PlayerEntity!

    override func setUp() {
        super.setUp()
        // Setup cannon
        cannonEntity = CannonEntity()
        spriteSystem = SpriteSystem()
        guard let sprite = cannonEntity.get(SpriteComponent.self) else {
            XCTFail("Failed to get cannon sprite")
            return
        }

        cannonNode = SKSpriteNode(imageNamed: "cannon")
        _ = spriteSystem.set(sprite: sprite, to: cannonNode)
        cannonSystem = CannonSystem(cannon: sprite)

        // Setup player
        playerEntity = PlayerEntity()
        playerSprite = SpriteComponent(parent: playerEntity)
        _ = spriteSystem.set(sprite: playerSprite, of: .player1, with: "Pink_Monster", at: CGPoint(x: 10, y: 20))
        _ = spriteSystem.setPhysicsBody(to: playerSprite, of: .player1)
    }

    override func tearDown() {
        cannonSystem = nil
        cannonEntity = nil
        cannonNode = nil
        spriteSystem = nil
        playerSprite = nil
        playerEntity = nil
        super.tearDown()
    }

    func testLaunchPlayer_zeroVelocity() {
        let velocity = CGVector(dx: 0, dy: 0)
        cannonSystem.launch(player: playerSprite, with: velocity)

        guard let physicsBody = playerSprite.node.physicsBody else {
            XCTFail("Failed to get physicsBody")
            return
        }
        XCTAssertTrue(physicsBody.isDynamic)
        XCTAssertEqual(physicsBody.velocity, velocity)
    }

    func testLaunchPlayer_positiveVelocity() {
        let velocity = CGVector(dx: 10, dy: 0)
        cannonSystem.launch(player: playerSprite, with: velocity)

        guard let physicsBody = playerSprite.node.physicsBody else {
            XCTFail("Failed to get physicsBody")
            return
        }
        XCTAssertTrue(physicsBody.isDynamic)
    }

    func testLaunchPlayer_negativeVelocity() {
        let velocity = CGVector(dx: -10, dy: 0)
        cannonSystem.launch(player: playerSprite, with: velocity)

        guard let physicsBody = playerSprite.node.physicsBody else {
            XCTFail("Failed to get physicsBody")
            return
        }
        XCTAssertTrue(physicsBody.isDynamic)
    }
}

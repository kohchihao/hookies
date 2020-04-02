//
//  SpriteSystemTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 2/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
import SpriteKit
class SpriteSystemTests: XCTestCase {

    var spriteSystem: SpriteSystem!

    override func setUp() {
        super.setUp()
        spriteSystem = SpriteSystem()
    }

    override func tearDown() {
        spriteSystem = nil
        super.tearDown()
    }

    func testSet() {
        let entity = PlayerEntity()
        let spriteComponent = SpriteComponent(parent: entity)
        entity.addComponent(spriteComponent)
        let sc = spriteSystem.set(
            sprite: spriteComponent,
            of: SpriteType.player1,
            with: "Pink_Monster",
            at: CGPoint(x: 0, y: 0))
        XCTAssertEqual(sc.node.position, CGPoint(x: 0, y: 0))
        XCTAssertEqual(sc.node.zPosition, SpriteType.player1.zPosition)
        XCTAssertEqual(sc.node.size, SpriteType.player1.size)
    }

    func testSetWithSpriteComponentAndSpriteNode() {
        let entity = PlayerEntity()
        let spriteComponent = SpriteComponent(parent: entity)
        entity.addComponent(spriteComponent)

        let node = SKSpriteNode(imageNamed: "Pink_Monster")
        let sc = spriteSystem.set(sprite: spriteComponent, to: node)
        XCTAssertEqual(sc, spriteComponent)
        XCTAssertEqual(sc.node, node)
    }

    func testSetPhysicsBodyRectangle() {
        let entity = PlayerEntity()
        let spriteComponent = SpriteComponent(parent: entity)
        entity.addComponent(spriteComponent)

        let sc = spriteSystem.setPhysicsBody(
            to: spriteComponent,
            of: SpriteType.player1,
            rectangleOf: CGSize(width: 100, height: 100))
        XCTAssertEqual(sc, spriteComponent)
        XCTAssertNotNil(sc.node.physicsBody)

        XCTAssertEqual(sc.node.physicsBody?.isDynamic, SpriteType.player1.isDynamic)
        XCTAssertEqual(sc.node.physicsBody?.affectedByGravity, SpriteType.player1.affectedByGravity)
        XCTAssertEqual(sc.node.physicsBody?.allowsRotation, SpriteType.player1.allowRotation)
        XCTAssertEqual(sc.node.physicsBody?.linearDamping, SpriteType.player1.linearDamping)
        XCTAssertEqual(sc.node.physicsBody?.friction, SpriteType.player1.friction)
        XCTAssertEqual(sc.node.physicsBody?.categoryBitMask, SpriteType.player1.bitMask)
        XCTAssertEqual(sc.node.physicsBody?.collisionBitMask, SpriteType.player1.collisionBitMask)
        XCTAssertEqual(sc.node.physicsBody?.contactTestBitMask, SpriteType.player1.contactTestBitMask)
    }

    func testSetPhysicsBodyCircle() {
        let entity = PlayerEntity()
        let spriteComponent = SpriteComponent(parent: entity)
        entity.addComponent(spriteComponent)

        let sc = spriteSystem.setPhysicsBody(
            to: spriteComponent,
            of: SpriteType.player1,
            circleOfRadius: 100)
        XCTAssertEqual(sc, spriteComponent)
        XCTAssertNotNil(sc.node.physicsBody)

        XCTAssertEqual(sc.node.physicsBody?.isDynamic, SpriteType.player1.isDynamic)
        XCTAssertEqual(sc.node.physicsBody?.affectedByGravity, SpriteType.player1.affectedByGravity)
        XCTAssertEqual(sc.node.physicsBody?.allowsRotation, SpriteType.player1.allowRotation)
        XCTAssertEqual(sc.node.physicsBody?.linearDamping, SpriteType.player1.linearDamping)
        XCTAssertEqual(sc.node.physicsBody?.friction, SpriteType.player1.friction)
        XCTAssertEqual(sc.node.physicsBody?.categoryBitMask, SpriteType.player1.bitMask)
        XCTAssertEqual(sc.node.physicsBody?.collisionBitMask, SpriteType.player1.collisionBitMask)
        XCTAssertEqual(sc.node.physicsBody?.contactTestBitMask, SpriteType.player1.contactTestBitMask)
    }
}

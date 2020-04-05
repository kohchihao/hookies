//
//  ClosestBoltSystemTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 5/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
import SpriteKit
@testable import Hookies
class ClosestBoltSystemTests: XCTestCase {

    var cbs: ClosestBoltSystem!
    var boltEntity: BoltEntity!
    var boltEntity1: BoltEntity!
    var boltEntity2: BoltEntity!

    var boltNode: SKSpriteNode!
    var boltNode1: SKSpriteNode!
    var boltNode2: SKSpriteNode!

    var boltSprite: SpriteComponent!
    var boltSprite1: SpriteComponent!
    var boltSprite2: SpriteComponent!

    var spriteSystem: SpriteSystem!

    var bolts: [SpriteComponent]!

    override func setUp() {
        super.setUp()
        boltEntity = BoltEntity()
        boltEntity1 = BoltEntity()
        boltEntity2 = BoltEntity()

        boltSprite = SpriteComponent(parent: boltEntity)
        boltSprite1 = SpriteComponent(parent: boltEntity1)
        boltSprite2 = SpriteComponent(parent: boltEntity2)

        spriteSystem = SpriteSystem()

        boltNode = SKSpriteNode()
        boltNode.position = CGPoint(x: 10, y: 10)
        boltNode1 = SKSpriteNode()
        boltNode1.position = CGPoint(x: 20, y: 10)
        boltNode2 = SKSpriteNode()
        boltNode2.position = CGPoint(x: 30, y: 10)

        _ = spriteSystem.set(sprite: boltSprite, to: boltNode)
        _ = spriteSystem.set(sprite: boltSprite1, to: boltNode1)
        _ = spriteSystem.set(sprite: boltSprite2, to: boltNode2)

        bolts = [boltSprite, boltSprite1, boltSprite2]
        cbs = ClosestBoltSystem(bolts: bolts)
    }

    override func tearDown() {
        cbs = nil
        boltEntity = nil
        boltEntity1 = nil
        boltEntity2 = nil

        boltSprite = nil
        boltSprite1 = nil
        boltSprite2 = nil

        boltNode = nil
        boltNode1 = nil
        boltNode2 = nil

        bolts = nil
        spriteSystem = nil
        super.tearDown()
    }

    func testFindClosestBolt() {
        let (prev, current) = cbs.findClosestBolt(to: CGPoint(x: 0, y: 10))
        XCTAssertEqual(current?.node.position, boltSprite.node.position)
        XCTAssertNil(prev)
    }

    func testFindClosestBolt_calledMultipleTimes() {
        let (prev, current) = cbs.findClosestBolt(to: CGPoint(x: 0, y: 10))
        XCTAssertEqual(current?.node.position, boltSprite.node.position)
        XCTAssertNil(prev)

        let (prev1, current1) = cbs.findClosestBolt(to: CGPoint(x: 16, y: 10))
        XCTAssertEqual(current1?.node.position, boltSprite1.node.position)
        XCTAssertNotNil(prev1)
        XCTAssertEqual(prev1?.node.position, boltSprite.node.position)
    }
}

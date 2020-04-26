//
//  HookSystemTests.swift
//  HookiesTests
//
//  Created by JinYing on 26/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
import SpriteKit

class HookSystemTests: XCTestCase {
    let hookNilMessage = "Cannot get hook component from entity"
    let hookToNilMessage = "Cannot get hookTo from hook"
    let prevHookToNilMessage = "Cannot get prevHookTo from hook"
    let spriteNilMessage = "Cannot get sprite component from entity"

    var sut: HookSystem!

    var spriteSystem: SpriteSystem!

    var playerEntity: PlayerEntity!
    var bolt1Entity: BoltEntity!
    var bolt2Entity: BoltEntity!

    var bolt1Sprite: SpriteComponent!
    var bolt2Sprite: SpriteComponent!
    var playerSprite: SpriteComponent!

    override func setUp() {
        super.setUp()

        spriteSystem = SpriteSystem()

        bolt1Entity = BoltEntity()
        bolt2Entity = BoltEntity()
        guard let bolt1Sprite = setUpTestBolt(at: CGPoint(x: 10, y: 10), to: bolt1Entity),
            let bolt2Sprite = setUpTestBolt(at: CGPoint(x: 20, y: 20), to: bolt2Entity)
            else {
                return
        }
        self.bolt1Sprite = bolt1Sprite
        self.bolt2Sprite = bolt2Sprite
        let bolts: [SpriteComponent] = [bolt1Sprite, bolt2Sprite]

        playerEntity = PlayerEntity()
        guard let playerSprite = setUpTestPlayer(at: CGPoint(x: 18, y: 18), to: playerEntity) else {
            return
        }
        self.playerSprite = playerSprite

        sut = HookSystem(bolts: bolts)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    private func setUpTestBolt(at position: CGPoint, to entity: BoltEntity) -> SpriteComponent? {
        guard let boltSprite = entity.get(SpriteComponent.self) else {
            XCTFail(spriteNilMessage)
            return nil
        }

        let boltNode = SKSpriteNode()
        boltNode.position = position
        _ = spriteSystem.set(sprite: boltSprite, to: boltNode)
        _ = spriteSystem.setPhysicsBody(to: boltSprite, of: .bolt)

        return boltSprite
    }

    private func setUpTestPlayer(at position: CGPoint, to entity: PlayerEntity) -> SpriteComponent? {
        guard let playerSprite = entity.get(SpriteComponent.self) else {
            XCTFail(spriteNilMessage)
            return nil
        }
        _ = spriteSystem.set(sprite: playerSprite, of: .player1, with: "Pink_Monster", at: position)
        _ = spriteSystem.setPhysicsBody(to: playerSprite, of: .player1, rectangleOf: playerSprite.node.size)

        return playerSprite
    }

    func testHook_fromEntity_shouldHookToClosestBolt() {
        let hasHook = sut.hook(from: playerEntity)
        guard let hook = playerEntity.get(HookComponent.self) else {
            XCTFail(hookNilMessage)
            return
        }
        guard let hookTo = hook.hookTo else {
            XCTFail(hookToNilMessage)
            return
        }

        XCTAssertTrue(hasHook)
        XCTAssertEqual(bolt2Sprite, hookTo)
        XCTAssertNotNil(hook.line)
        XCTAssertNotNil(hook.anchorLineJointPin)
        XCTAssertNotNil(hook.parentLineJointPin)
    }

    func testHook_fromEntity_shouldBroadcast() {
        expectation(
            forNotification: .broadcastGenericPlayerAction,
            object: sut,
            handler: nil)

        let hasHook = sut.hook(from: playerEntity)

        XCTAssertTrue(hasHook)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUnhook_withNoHook() {
        let hasUnhook = sut.unhook(entity: playerEntity)
        guard let hook = playerEntity.get(HookComponent.self) else {
            XCTFail(hookNilMessage)
            return
        }

        XCTAssertTrue(hasUnhook)
        XCTAssertNil(hook.prevHookTo)
        XCTAssertNil(hook.hookTo)
        XCTAssertNil(hook.line)
        XCTAssertNil(hook.anchorLineJointPin)
        XCTAssertNil(hook.parentLineJointPin)
    }

    func testUnhook_entity_shouldBroadcast() {
        expectation(
            forNotification: .broadcastGenericPlayerAction,
            object: sut,
            handler: nil)

        let hasHook = sut.unhook(entity: playerEntity)

        XCTAssertTrue(hasHook)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUnhook_entity_shouldUnhook() {
        _ = sut.hook(from: playerEntity)
        let hasUnhook = sut.unhook(entity: playerEntity)
        guard let hook = playerEntity.get(HookComponent.self) else {
            XCTFail(hookNilMessage)
            return
        }
        guard let prevHookTo = hook.prevHookTo else {
            XCTFail(prevHookToNilMessage)
            return
        }

        XCTAssertTrue(hasUnhook)
        XCTAssertEqual(bolt2Sprite, prevHookTo)
        XCTAssertNil(hook.hookTo)
        XCTAssertNil(hook.line)
        XCTAssertNil(hook.anchorLineJointPin)
        XCTAssertNil(hook.parentLineJointPin)
    }

    func testUnhook_entityAtPositionAndVelocity_shouldUnhook() {
        let position = CGPoint(x: 30, y: 25)
        let velocity = CGVector(dx: 55, dy: 33)

        _ = sut.hook(from: playerEntity)
        let hasUnhook = sut.unhook(entity: playerEntity, at: position, with: velocity)
        guard let hook = playerEntity.get(HookComponent.self) else {
            XCTFail(hookNilMessage)
            return
        }
        guard let prevHookTo = hook.prevHookTo else {
            XCTFail(prevHookToNilMessage)
            return
        }
        guard let playerSprite = playerEntity.get(SpriteComponent.self) else {
            XCTFail(spriteNilMessage)
            return
        }

        XCTAssertTrue(hasUnhook)
        XCTAssertEqual(position, playerSprite.node.position)
        XCTAssertEqual(velocity, playerSprite.node.physicsBody?.velocity)
        XCTAssertEqual(bolt2Sprite, prevHookTo)
        XCTAssertNil(hook.hookTo)
        XCTAssertNil(hook.line)
        XCTAssertNil(hook.anchorLineJointPin)
        XCTAssertNil(hook.parentLineJointPin)
    }

    //    func testApplyInitialVelocity_shouldApply() {
    //        let initialVelocity = CGVector(dx: 230, dy: 404)
    //
    //        sut.applyInitialVelocity(sprite: playerSprite, velocity: initialVelocity)
    //
    //        XCTAssertEqual(initialVelocity, playerSprite.node.physicsBody?.velocity)
    //    }
    //
    //    func testBoostVelocity_attachingToSameBolt_shouldNotBoost() {
    //        _ = sut.hook(from: playerEntity)
    //        _ = sut.unhook(entity: playerEntity)
    //        _ = sut.hook(from: playerEntity)
    //
    //        sut.boostVelocity(to: playerEntity)
    //        XCTAssertEqual(CGVector(dx: 0, dy: 0), playerSprite.node.physicsBody?.velocity)
    //    }
    //
    //    func testBoostVelocity_attachingToDifferentBolt_shouldBoost() {
    //        let boostVelocity = CGVector(dx: 1000, dy: -1000)
    //        _ = sut.hook(from: playerEntity)
    //
    //        sut.boostVelocity(to: playerEntity)
    //
    //        XCTAssertEqual(boostVelocity, playerSprite.node.physicsBody?.velocity)
    //    }

    func testIsShorterThanMin_shorterThanMin_returnTrue() {
        _ = sut.hook(from: playerEntity)

        let isShorter = sut.isShorterThanMin(for: playerEntity)

        XCTAssertTrue(isShorter)
    }

    func testIsShorterThanMin_equalToMin_returnFalse() {
        playerSprite.node.position = CGPoint(x: 20, y: 120)
        _ = sut.hook(from: playerEntity)

        let isShorter = sut.isShorterThanMin(for: playerEntity)

        XCTAssertFalse(isShorter)
    }

    func testIsShorterThanMin_longerThanMin_returnFalse() {
        playerSprite.node.position = CGPoint(x: 20, y: 121)
        _ = sut.hook(from: playerEntity)

        let isShorter = sut.isShorterThanMin(for: playerEntity)

        XCTAssertFalse(isShorter)
    }

    func testIsShorterThanMin_noHook_returnFalse() {
        let isShorter = sut.isShorterThanMin(for: playerEntity)

        XCTAssertFalse(isShorter)
    }

    func testAdjustLength_entity_shorten_bottomLeftOfBolt_shouldShorten() {
        let initialXPos = playerSprite.node.position.x
        let initialYPos = playerSprite.node.position.y

        _ = sut.hook(from: playerEntity)
        let hasAdjusted = sut.adjustLength(from: playerEntity, type: .shorten)

        guard let hook = playerEntity.get(HookComponent.self) else {
            XCTFail(hookNilMessage)
            return
        }
        guard let hookTo = hook.hookTo else {
            XCTFail(hookToNilMessage)
            return
        }

        XCTAssertTrue(hasAdjusted)
        XCTAssertTrue(initialXPos < playerSprite.node.position.x)
        XCTAssertTrue(initialYPos < playerSprite.node.position.y)
        XCTAssertEqual(bolt2Sprite, hookTo)
        XCTAssertNotNil(hook.line)
        XCTAssertNotNil(hook.anchorLineJointPin)
        XCTAssertNotNil(hook.parentLineJointPin)
    }

    func testAdjustLength_entity_shorten_topRightOfBolt_shouldShorten() {
        let initialXPos: CGFloat = 30
        let initialYPos: CGFloat = 30

        playerSprite.node.position = CGPoint(x: initialXPos, y: initialYPos)
        _ = sut.hook(from: playerEntity)
        let hasAdjusted = sut.adjustLength(from: playerEntity, type: .shorten)

        guard let hook = playerEntity.get(HookComponent.self) else {
            XCTFail(hookNilMessage)
            return
        }
        guard let hookTo = hook.hookTo else {
            XCTFail(hookToNilMessage)
            return
        }

        XCTAssertTrue(hasAdjusted)
        XCTAssertTrue(initialXPos > playerSprite.node.position.x)
        XCTAssertTrue(initialYPos > playerSprite.node.position.y)
        XCTAssertEqual(bolt2Sprite, hookTo)
        XCTAssertNotNil(hook.line)
        XCTAssertNotNil(hook.anchorLineJointPin)
        XCTAssertNotNil(hook.parentLineJointPin)
    }

    func testAdjustLength_entity_lengthen_shouldLengthen() {
        let initialXPos: CGFloat = 30
        let initialYPos: CGFloat = 30

        playerSprite.node.position = CGPoint(x: initialXPos, y: initialYPos)
        _ = sut.hook(from: playerEntity)
        let hasAdjusted = sut.adjustLength(from: playerEntity, type: .lengthen)

        guard let hook = playerEntity.get(HookComponent.self) else {
            XCTFail(hookNilMessage)
            return
        }
        guard let hookTo = hook.hookTo else {
            XCTFail(hookToNilMessage)
            return
        }

        XCTAssertTrue(hasAdjusted)
        XCTAssertTrue(initialXPos < playerSprite.node.position.x)
        XCTAssertTrue(initialYPos < playerSprite.node.position.y)
        XCTAssertEqual(bolt2Sprite, hookTo)
        XCTAssertNotNil(hook.line)
        XCTAssertNotNil(hook.anchorLineJointPin)
        XCTAssertNotNil(hook.parentLineJointPin)

    }

    func testAdjustLength_shorten_shouldBroadcast() {
        expectation(
            forNotification: .broadcastGenericPlayerAction,
            object: sut,
            handler: nil)

        _ = sut.adjustLength(from: playerEntity, type: .shorten)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAdjustLength_noHook_returnFalse() {
        let hasAdjusted = sut.adjustLength(from: playerEntity, type: .shorten)

        XCTAssertFalse(hasAdjusted)
    }
}

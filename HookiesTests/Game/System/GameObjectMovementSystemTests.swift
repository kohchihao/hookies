//
//  GameObjectMovementSystemTests.swift
//  HookiesTests
//
//  Created by Marcus Koh on 4/4/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import XCTest
@testable import Hookies
import SpriteKit
class GameObjectMovementSystemTests: XCTestCase {

    var gom: GameObjectMovementSystem!
    var rotate: RotateComponent!
    var translate: NonPhysicsTranslateComponent!
    var bounce: BounceComponent!
    var platformEntity: PlatformEntity!

    var spriteSystem: SpriteSystem!
    var platformSprite: SpriteComponent!
    var platformNode: SKSpriteNode!

    var path: CGMutablePath!

    override func setUp() {
        super.setUp()
        spriteSystem = SpriteSystem()
        platformEntity = PlatformEntity()
        platformSprite = SpriteComponent(parent: platformEntity)
        platformNode = SKSpriteNode()
        platformNode.position = CGPoint(x: 10, y: 10)
        _ = spriteSystem.set(sprite: platformSprite, to: platformNode)

        gom = GameObjectMovementSystem()
        platformEntity = PlatformEntity()
        rotate = RotateComponent(parent: platformEntity)
        translate = NonPhysicsTranslateComponent(parent: platformEntity)
        bounce = BounceComponent(parent: platformEntity)
        platformEntity.addComponent(rotate)
        platformEntity.addComponent(translate)
        platformEntity.addComponent(bounce)

        path = CGMutablePath()
    }

    override func tearDown() {
        gom = nil
        rotate = nil
        translate = nil
        bounce = nil
        platformEntity = nil

        spriteSystem = nil
        platformSprite = nil
        platformNode = nil
        super.tearDown()
    }

    func testSetRotationNegativeDuration() {
        gom.setRotation(to: platformSprite, with: rotate, withDuration: -1, withAngle: -1)
        XCTAssertEqual(rotate.duration, 0.0)
        XCTAssertEqual(rotate.radianAngle, 0.0)
    }

    func testSetRotationPositiveDuration() {
        gom.setRotation(to: platformSprite, with: rotate, withDuration: 5, withAngle: -1)
        XCTAssertEqual(rotate.duration, 5.0)
        XCTAssertEqual(rotate.radianAngle, -1)
    }

    func testSetRotationZeroDuration() {
        gom.setRotation(to: platformSprite, with: rotate, withDuration: 0, withAngle: -1)
        XCTAssertEqual(rotate.duration, 0)
        XCTAssertEqual(rotate.radianAngle, -1)
    }

    func testSetTranslationNegativeSpeed() {
        gom.setTranslation(to: platformSprite, with: translate, withPath: path, moveInfinitely: true, speed: -1)
        XCTAssertEqual(translate.path, path)
        XCTAssertFalse(translate.moveInfinitely)
        XCTAssertEqual(translate.speed, 0.0)
    }

    func testSetTranslationPositiveSpeed() {
        gom.setTranslation(to: platformSprite, with: translate, withPath: path, moveInfinitely: true, speed: 1)
        XCTAssertEqual(translate.path, path)
        XCTAssertTrue(translate.moveInfinitely)
        XCTAssertEqual(translate.speed, 1.0)
    }

    func testSetTranslationZeroSpeed() {
        gom.setTranslation(to: platformSprite, with: translate, withPath: path, moveInfinitely: true, speed: 0)
        XCTAssertEqual(translate.path, path)
        XCTAssertTrue(translate.moveInfinitely)
        XCTAssertEqual(translate.speed, 0.0)
    }

    func testSetBounceNegativeRestitution() {
        gom.setBounce(to: platformSprite, with: bounce, withRestitution: -1)
        XCTAssertEqual(bounce.restitution, 0.0)
    }

    func testSetBounceLessThanOneRestitution() {
        gom.setBounce(to: platformSprite, with: bounce, withRestitution: 0.5)
        XCTAssertEqual(bounce.restitution, 0.5)
    }

    func testSetBouncePositiveOneRestitution() {
        gom.setBounce(to: platformSprite, with: bounce, withRestitution: 1)
        XCTAssertEqual(bounce.restitution, 1)
    }

    func testSetBounceMoreThanOneRestitution() {
        gom.setBounce(to: platformSprite, with: bounce, withRestitution: 1.2)
        XCTAssertEqual(bounce.restitution, 0.0)
    }

    func testSetTranslationRectangleNegativeSpeedWidthHeight() {
        gom.setTranslationRectangle(
            to: platformSprite, with: translate,
            moveInfinitely: true,
            speed: -50, width: -100, height: -100)
        XCTAssertEqual(translate.speed, 0.0)
        XCTAssertFalse(translate.moveInfinitely)
    }

    func testSetTranslationRectanglePositiveSpeedWidthHeight() {
        gom.setTranslationRectangle(
            to: platformSprite, with: translate,
            moveInfinitely: true,
            speed: 50, width: 50, height: 50)
        XCTAssertEqual(translate.speed, 50.0)
        XCTAssertTrue(translate.moveInfinitely)
    }

    func testSetTranslationCircleNegativeSpeedRadius() {
        gom.setTranslationCircle(
            to: platformSprite, with: translate,
            moveInfinitely: true,
            speed: -50, radius: -100)
        XCTAssertEqual(translate.speed, 0.0)
        XCTAssertFalse(translate.moveInfinitely)
    }

    func testSetTranslationCirclePositiveSpeedRadius() {
        gom.setTranslationCircle(
            to: platformSprite, with: translate,
            moveInfinitely: true,
            speed: 50, radius: 100)
        XCTAssertEqual(translate.speed, 50.0)
        XCTAssertTrue(translate.moveInfinitely)
    }

    func testSetTranslationLineNegativeSpeed() {
        gom.setTranslationLine(
            to: platformSprite, with: translate,
            moveInfinitely: true,
            speed: -50, endingAt: CGPoint(x: 100, y: 100))
        XCTAssertEqual(translate.speed, 0.0)
        XCTAssertFalse(translate.moveInfinitely)
    }

    func testSetTranslationLinePositiveSpeed() {
        gom.setTranslationLine(
            to: platformSprite, with: translate,
            moveInfinitely: true,
            speed: 50, endingAt: CGPoint(x: 100, y: 100))
        XCTAssertEqual(translate.speed, 50.0)
        XCTAssertTrue(translate.moveInfinitely)
    }

    func testRemoveRotateComponent_exists() {
        gom.setRotation(to: platformSprite, with: rotate, withDuration: 5, withAngle: -1)
        XCTAssertEqual(rotate.duration, 5.0)
        XCTAssertEqual(rotate.radianAngle, -1)

        XCTAssertNotNil(gom.remove(rotate: rotate))
    }

    func testRemoveRotateComponent_doesNotExists() {
        XCTAssertNil(gom.remove(rotate: rotate))
    }

    func testRemoveTranslateComponent_exists() {
        gom.setTranslation(to: platformSprite, with: translate, withPath: path, moveInfinitely: true, speed: 1)
        XCTAssertEqual(translate.path, path)
        XCTAssertTrue(translate.moveInfinitely)
        XCTAssertEqual(translate.speed, 1.0)

        XCTAssertNotNil(gom.remove(translate: translate))
    }

    func testRemoveTranslateComponent_doesNotExists() {
        XCTAssertNil(gom.remove(translate: translate))
    }

    func testRemoveBounceComponent_exists() {
        gom.setBounce(to: platformSprite, with: bounce, withRestitution: 0.5)
        XCTAssertEqual(bounce.restitution, 0.5)

        XCTAssertNotNil(gom.remove(bounce: bounce))
    }

    func testRemoveBounceComponent_doesNotExists() {
        XCTAssertNil(gom.remove(bounce: bounce))
    }
}

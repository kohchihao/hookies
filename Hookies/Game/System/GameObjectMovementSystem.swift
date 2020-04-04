//
//  GameObjectMovement.swift
//  Hookies
//
//  Created by Marcus Koh on 24/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

/// Moves all the game object within the world.

protocol GameObjectMovementSystemProtocol {
    func remove(rotate: RotateComponent) -> RotateComponent?
    func remove(translate: NonPhysicsTranslateComponent) -> NonPhysicsTranslateComponent?
    func remove(bounce: BounceComponent) -> BounceComponent?
    func removeAll()
    func update()
    func setRotation(
        to sprite: SpriteComponent,
        with rotate: RotateComponent,
        withDuration duration: Double,
        withAngle angle: Double)
    func setTranslation(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        withPath path: CGMutablePath,
        moveInfinitely: Bool,
        speed: Double)
    func setTranslationRectangle(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        moveInfinitely: Bool,
        speed: Double,
        width: Double,
        height: Double)
    func setTranslationCircle(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        moveInfinitely: Bool,
        speed: Double,
        radius: Double)
    func setTranslationLine(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        moveInfinitely: Bool,
        speed: Double,
        endingAt: CGPoint)
    func setBounce(
        to sprite: SpriteComponent,
        with bounce: BounceComponent,
        withRestitution restitution: Double)
}

class GameObjectMovementSystem: System, GameObjectMovementSystemProtocol {
    private var spriteToRotate = [SpriteComponent: RotateComponent]()
    private var spriteToTranslate = [SpriteComponent: NonPhysicsTranslateComponent]()
    private var spriteToBounce = [SpriteComponent: BounceComponent]()

    // MARK: - Remove components

    func remove(rotate: RotateComponent) -> RotateComponent? {
        guard let index = spriteToRotate.firstIndex(where: { $0.value == rotate }) else {
            return nil
        }
        return spriteToRotate.remove(at: index).value
    }

    func remove(translate: NonPhysicsTranslateComponent) -> NonPhysicsTranslateComponent? {
        guard let index = spriteToTranslate.firstIndex(where: { $0.value == translate }) else {
            return nil
        }
        return spriteToTranslate.remove(at: index).value
    }

    func remove(bounce: BounceComponent) -> BounceComponent? {
        guard let index = spriteToBounce.firstIndex(where: { $0.value == bounce }) else {
            return nil
        }
        return spriteToBounce.remove(at: index).value
    }

    func removeAll() {
        spriteToRotate.removeAll()
        spriteToTranslate.removeAll()
        spriteToBounce.removeAll()
    }

    // MARK: - Update

    func update() {
        setSpriteBounce()
        let rotateGroup = addRotateAction()
        let (translateGroup, reverseTranslateGroup) = addTranslateAction()

        var translateRotateGroup = translateGroup.merging(rotateGroup, uniquingKeysWith: +)
        var reverseTranslateRotateGroup = reverseTranslateGroup.merging(rotateGroup, uniquingKeysWith: +)

        translateRotateGroup = translateRotateGroup.mapValues({ value in
            [SKAction.group(value)]
        })

        reverseTranslateRotateGroup = reverseTranslateRotateGroup.mapValues({ value in
            [SKAction.group(value)]
        })

        let finalSequence = translateRotateGroup.merging(reverseTranslateRotateGroup, uniquingKeysWith: +)
        for (sprite, sequence) in finalSequence {
            sprite.node.run(SKAction.repeatForever(SKAction.sequence(sequence)))
        }
    }

    private func addRotateAction() -> [SpriteComponent: [SKAction]] {
        var rotateGroup = [SpriteComponent: [SKAction]]()
        for (sprite, rotate) in spriteToRotate {
            let rotateAction = SKAction.rotate(byAngle: CGFloat(rotate.radianAngle), duration: rotate.duration)
            if var actionGroup = rotateGroup[sprite] {
                actionGroup.append(rotateAction)
                rotateGroup[sprite] = actionGroup
            } else {
                rotateGroup[sprite] = [rotateAction]
            }
        }
        return rotateGroup
    }

    private func addTranslateAction() -> ([SpriteComponent: [SKAction]], [SpriteComponent: [SKAction]]) {
        var translateGroup = [SpriteComponent: [SKAction]]()
        var reverseTranslateGroup = [SpriteComponent: [SKAction]]()

        for (sprite, translate) in spriteToTranslate {
            let pathAction = SKAction.follow(
                translate.path,
                asOffset: false,
                orientToPath: false,
                speed: CGFloat(translate.speed))

            if var actionGroup = translateGroup[sprite] {
                actionGroup.append(pathAction)
                translateGroup[sprite] = actionGroup
            } else {
                translateGroup[sprite] = [pathAction]
            }

            if translate.moveInfinitely {
                let reversedPathAction = pathAction.reversed()
                if var actionGroup = reverseTranslateGroup[sprite] {
                    actionGroup.append(reversedPathAction)
                    reverseTranslateGroup[sprite] = actionGroup
                } else {
                    reverseTranslateGroup[sprite] = [reversedPathAction]
                }
            }
        }
        return (translateGroup, reverseTranslateGroup)
    }

    private func setSpriteBounce() {
        for (sprite, bounce) in spriteToBounce {
            sprite.node.physicsBody?.restitution = CGFloat(bounce.restitution)
        }
    }

    // MARK: - Setting Rotation

    func setRotation(
        to sprite: SpriteComponent,
        with rotate: RotateComponent,
        withDuration duration: Double,
        withAngle angle: Double
    ) {
        rotate.duration = duration
        rotate.radianAngle = angle

        spriteToRotate[sprite] = rotate
    }

    // MARK: - Setting Translation

    func setTranslation(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        withPath path: CGMutablePath,
        moveInfinitely: Bool,
        speed: Double
    ) {
        translate.path = path
        translate.moveInfinitely = moveInfinitely
        translate.speed = speed

        spriteToTranslate[sprite] = translate
    }

    // MARK: - Setting Bounce

    func setBounce(
        to sprite: SpriteComponent,
        with bounce: BounceComponent,
        withRestitution restitution: Double
    ) {
        bounce.restitution = restitution
        spriteToBounce[sprite] = bounce
    }

    func setTranslationRectangle(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        moveInfinitely: Bool,
        speed: Double,
        width: Double,
        height: Double
    ) {
        let path = createRectangleShapePath(starting: sprite.node.position, width: width, height: height)
        self.setTranslation(to: sprite, with: translate, withPath: path, moveInfinitely: moveInfinitely, speed: speed)
    }

    func setTranslationCircle(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        moveInfinitely: Bool,
        speed: Double,
        radius: Double
    ) {
        let path = createCircleShapePath(starting: sprite.node.position, radius: radius)
        self.setTranslation(to: sprite, with: translate, withPath: path, moveInfinitely: moveInfinitely, speed: speed)
    }

    func setTranslationLine(
        to sprite: SpriteComponent,
        with translate: NonPhysicsTranslateComponent,
        moveInfinitely: Bool,
        speed: Double,
        endingAt: CGPoint
    ) {
        let path = createLineShapePath(starting: sprite.node.position, ending: endingAt)
        self.setTranslation(to: sprite, with: translate, withPath: path, moveInfinitely: moveInfinitely, speed: speed)
    }

    private func createRectangleShapePath(
        starting position: CGPoint,
        width: Double,
        height: Double
    ) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: position)
        path.addLine(to: CGPoint(x: position.x + CGFloat(width), y: position.y))
        path.addLine(to: CGPoint(x: position.x + CGFloat(width), y: position.y - CGFloat(height)))
        path.addLine(to: CGPoint(x: position.x, y: position.y - CGFloat(height)))
        path.addLine(to: CGPoint(x: position.x, y: position.y))
        path.closeSubpath()
        return path
    }

    private func createCircleShapePath(starting position: CGPoint, radius: Double) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: position)
        let rect = CGRect(x: position.x, y: position.y, width: CGFloat(radius) * 2, height: CGFloat(radius) * 2)
        path.addEllipse(in: rect)
        path.closeSubpath()
        return path
    }

    private func createLineShapePath(starting startPosition: CGPoint, ending endPosition: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: startPosition)
        path.addLine(to: endPosition)
        path.closeSubpath()
        return path
    }
}

//
//  HookSystem.swift
//  Hookies
//
//  Created by JinYing on 28/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Represent entity that will be potentially hooked to another entity

enum HookSystemAction {
    case lengthen, shorten
}

typealias AboveBoltDisplacement = Int
typealias BelowBoltDisplacement = Int
typealias RightBoltDisplacement = Int
typealias LeftBoltDisplacement = Int

protocol HookSystemProtocol {
    func hook(from hook: Entity) -> Bool
    func hook(from entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool
    func unhook(entity: Entity) -> Bool
    func unhook(entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool
    func applyInitialVelocity(sprite: SpriteComponent, velocity: CGVector)
    func boostVelocity(to entity: Entity)
}

enum HookSystemError: Error {
    case hookComponentDoesNotExist
    case spriteComponentDoesNotExist
    case closestHookToEntityDoesNotExist
    case physicsBodyDoesNotExist
}

class HookSystem: System, HookSystemProtocol {
    private var hooks: Set<HookComponent>
    private var bolts: [SpriteComponent]
    private let minRopeLength = 100.0
    private let maxRopeLength = 1000.0

    init(bolts: [SpriteComponent]) {
        self.hooks = Set<HookComponent>()
        self.bolts = bolts
    }

    // MARK: - Hook

    func hook(from entity: Entity) -> Bool {
        guard let sprite = entity.getSpriteComponent() else {
            return false
        }

        guard let velocity = sprite.node.physicsBody?.velocity else {
            return false
        }

        return hook(from: entity, at: sprite.node.position, with: velocity)
    }

    func hook(from entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool {
        guard let sprite = entity.getSpriteComponent(),
            let hook = entity.getHookComponent()
            else {
            return false
        }

        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        guard let closestBolt = findClosestBolt(from: sprite.node.position) else {
            return false
        }

        let line = sprite.makeLine(to: closestBolt)

        guard let anchorLineJointPin = makeJointPinToLine(from: closestBolt.node, toLine: line),
            let spriteLineJointPin = makeJointPinToLine(from: sprite.node, toLine: line) else {
                return false
        }

        hook.hookTo = closestBolt
        hook.line = line
        hook.anchorLineJointPin = anchorLineJointPin
        hook.parentLineJointPin = spriteLineJointPin

        return true
    }

    // MARK: - Adjust length

    func adjustLength(from entity: Entity, type: HookSystemAction) -> Bool {
        guard let sprite = entity.getSpriteComponent(),
            let hook = entity.getHookComponent()
            else {
                return false
        }

        guard let bolt = hook.hookTo else {
            return false
        }

        adjustRope(sprite: sprite, bolt: bolt, type: type)

        let line = sprite.makeLine(to: bolt)

        guard let anchorLineJointPin = makeJointPinToLine(from: bolt.node, toLine: line),
            let spriteLineJointPin = makeJointPinToLine(from: sprite.node, toLine: line)
            else {
                return false
        }

        hook.line = line
        hook.anchorLineJointPin = anchorLineJointPin
        hook.parentLineJointPin = spriteLineJointPin

        return true
    }

    // MARK: - Rope Checks

    func isShorterThanMin(for entity: Entity) -> Bool {
        guard let sprite = entity.getSpriteComponent(),
            let hook = entity.getHookComponent()
            else {
                return false
        }

        guard let bolt = hook.hookTo else {
            return false
        }

        let newPositionVector = Vector(point: sprite.node.position)
        let boltPositionVector = Vector(point: bolt.node.position)
        let ropeLength = newPositionVector.distance(to: boltPositionVector)
        if ropeLength < minRopeLength {
            return true
        }

        return false
    }


    // MARK: - Rope Utility

    private func adjustRope(
        sprite: SpriteComponent,
        bolt: SpriteComponent,
        type: HookSystemAction
    ) {
        let newPosition = getNewSpritePosition(sprite: sprite, bolt: bolt, type: type)

        if type == .lengthen && !isCollidingWithPlatform(sprite: sprite) {
            sprite.node.position = newPosition
        } else if type == .shorten {
            sprite.node.position = newPosition
        }
    }

    private func getNewSpritePosition(
        sprite: SpriteComponent,
        bolt: SpriteComponent,
        type: HookSystemAction
    ) -> CGPoint {
        let (aboveDisplacement, belowDisplacement) = getVerticalBoltDisplacement(for: type)
        let (rightDisplacement, leftDisplacement) = getHorizontalBoltDisplacement(for: type)

        var positionYOffset = CGFloat(0)
        var positionXOffset = CGFloat(0)

        let isAboveBolt = sprite.node.position.y > bolt.node.position.y
        let isBelowBolt = sprite.node.position.y < bolt.node.position.y
        let isLeftsideBolt = sprite.node.position.x < bolt.node.position.x
        let isRightsideBolt = sprite.node.position.x > bolt.node.position.x

        if isAboveBolt {
            positionYOffset = CGFloat(aboveDisplacement)
        }

        if isBelowBolt {
            positionYOffset = CGFloat(belowDisplacement)
        }

        if isRightsideBolt {
            positionXOffset = CGFloat(rightDisplacement)
        }

        if isLeftsideBolt {
            positionXOffset = CGFloat(leftDisplacement)
        }
        return CGPoint(
            x: sprite.node.position.x + positionXOffset,
            y: sprite.node.position.y + positionYOffset)
    }

    private func getHorizontalBoltDisplacement(
        for type: HookSystemAction
    ) -> (RightBoltDisplacement, LeftBoltDisplacement) {
        var rightBoltDisplacement = -3
        var leftBoltDisplacement = 3

        if type == .lengthen {
            rightBoltDisplacement *= -1
            leftBoltDisplacement *= -1
        }

        return (rightBoltDisplacement, leftBoltDisplacement)
    }

    private func getVerticalBoltDisplacement(
        for type: HookSystemAction
    ) -> (AboveBoltDisplacement, BelowBoltDisplacement) {
        var aboveBoltDisplacement = -3
        var belowBoltDisplacement = 3

        if type == .lengthen {
            aboveBoltDisplacement *= -1
            belowBoltDisplacement *= -1
        }

        return (aboveBoltDisplacement, belowBoltDisplacement)
    }

    private func isCollidingWithPlatform(sprite: SpriteComponent) -> Bool {
        guard let physicsBody = sprite.node.physicsBody else {
            return false
        }
        let contactedPhysicsBodies = physicsBody.allContactedBodies()
        for contactedBody in contactedPhysicsBodies {
            guard let spriteNode = contactedBody.node as? SKSpriteNode else {
                return false
            }
            if spriteNode.name == GameObjectType.platform.rawValue
                || spriteNode.name == GameObjectType.platformMovable.rawValue {
                return true
            }
        }

        return false
    }

    // MARK: - Unhook

    func unhook(entity: Entity) -> Bool {
        guard let sprite = entity.getSpriteComponent() else {
            return false
        }

        guard let velocity = sprite.node.physicsBody?.velocity else {
            return false
        }

        return unhook(entity: entity, at: sprite.node.position, with: velocity)
    }

    func unhook(entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool {
        guard let sprite = entity.getSpriteComponent(),
            let hook = entity.getHookComponent()
            else {
            return false
        }

        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        hook.prevHookTo = hook.hookTo
        hook.hookTo = nil
        hook.line = nil
        hook.anchorLineJointPin = nil
        hook.parentLineJointPin = nil

        return true
    }

    // MARK: - Add Initial Velocity

    func applyInitialVelocity(sprite: SpriteComponent, velocity: CGVector) {
        sprite.node.physicsBody?.applyImpulse(velocity)
    }

    // MARK: - Booster

    func boostVelocity(to entity: Entity) {
        guard let hook = entity.getHookComponent() else {
            return
        }

        let isAttachingToSameBolt = hook.hookTo == hook.prevHookTo

        if !isAttachingToSameBolt {
            guard let sprite = entity.getSpriteComponent(),
                let bolt = hook.hookTo else {
                return
            }

            var boostX = 1_000
            let boostY = -1_000

            let isInFrontOfBolt = sprite.node.position.x > bolt.node.position.x

            if isInFrontOfBolt {
                boostX *= -1
            }

            let boost = CGVector(dx: boostX, dy: boostY)
            sprite.node.physicsBody?.applyImpulse(boost)
        }
    }

    // MARK: - Find Closest Bolt

    private func findClosestBolt(from position: CGPoint) -> SpriteComponent? {
        var closestBolt: SpriteComponent?
        var closestDistance = Double.greatestFiniteMagnitude
        let positionVector = Vector(point: position)
        for bolt in bolts {
            let boltVectorPosition = Vector(point: bolt.node.position)
            let distance = positionVector.distance(to: boltVectorPosition)
            closestDistance = min(Double(distance), closestDistance)
            if closestDistance == Double(distance) {
                closestBolt = bolt
            }
        }

        return closestBolt
    }

    // MARK: - Create Joint

    private func makeJointPinToLine(from node: SKNode, toLine line: SKShapeNode) -> SKPhysicsJointPin? {
        guard let nodePhysicsBody = node.physicsBody,
            let linePhysicsBody = line.physicsBody
            else {
                return nil
        }

        let jointPin = SKPhysicsJointPin.joint(
            withBodyA: nodePhysicsBody,
            bodyB: linePhysicsBody,
            anchor: node.position
        )

        return jointPin
    }

    private func attachToSameBolt(sprite: SpriteComponent, bolt: SpriteComponent) {
        var positionYOffset = CGFloat(0)

        let isAboveBolt = sprite.node.position.y > bolt.node.position.y
        let isBelowBolt = sprite.node.position.y < bolt.node.position.y

        if isAboveBolt {
            positionYOffset = CGFloat(-15)
        }

        if isBelowBolt {
            positionYOffset = CGFloat(15)
        }

        sprite.node.position = CGPoint(x: sprite.node.position.x, y: sprite.node.position.y + positionYOffset)
    }
}

// MARK: - Broadcast Update

extension HookSystem {
    func broadcastUpdate(gameId: String, playerId: String, player: SpriteComponent, type: HookActionType) {
        guard let hookActionData = createHookAction(from: playerId, and: player, of: type) else {
            return
        }

        API.shared.gameplay.broadcastHookAction(hookAction: hookActionData)
    }

    private func createHookAction(
        from playerId: String,
        and player: SpriteComponent,
        of type: HookActionType
    ) -> HookActionData? {
        let hookActionData = HookActionData(
            playerId: playerId,
            position: Vector(point: player.node.position),
            velocity: Vector(vector: player.node.physicsBody?.velocity),
            type: type
        )

        return hookActionData
    }
}

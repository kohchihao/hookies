//
//  HookSystem.swift
//  Hookies
//
//  Created by JinYing on 28/3/20.
//  Copyright © 2020 Hookies. All rights reserved.
//

import SpriteKit

/// Represent entity that will be potentially hooked to another entity

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

    init(bolts: [SpriteComponent]) {
        self.hooks = Set<HookComponent>()
        self.bolts = bolts
    }

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

        let isAttachingToSameBolt = hook.prevHookTo?.node.position == closestBolt.node.position

        if isAttachingToSameBolt {
            attachToSameBolt(sprite: sprite, bolt: closestBolt)
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

    func applyInitialVelocity(sprite: SpriteComponent, velocity: CGVector) {
        sprite.node.physicsBody?.applyImpulse(velocity)
    }

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

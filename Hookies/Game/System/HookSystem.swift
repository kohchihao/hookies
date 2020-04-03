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
    func add(hook: HookComponent) -> HookComponent
    func hookTo(hook: HookComponent) -> Bool
    func hookTo(hook: HookComponent, at position: CGPoint, with velocity: CGVector) -> Bool
    func unhookFrom(entity: Entity) -> Bool
    func unhookFrom(entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool
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

    func add(hook: HookComponent) -> HookComponent {
        let (_, element) = hooks.insert(hook)

        return element
    }

    func hookTo(hook: HookComponent) -> Bool {
        guard let systemHook = hooks.first(where: { $0 == hook }) else {
            return false
        }

        guard let parentSprite = getParentSprite(of: systemHook) else {
            return false
        }

        guard let velocity = parentSprite.node.physicsBody?.velocity else {
            return false
        }

        return hookTo(hook: systemHook, at: parentSprite.node.position, with: velocity)
    }

    func hookTo(hook: HookComponent, at position: CGPoint, with velocity: CGVector) -> Bool {
        guard let systemHook = hooks.first(where: { $0 == hook }) else {
            return false
        }

        guard let parentSprite = getParentSprite(of: systemHook) else {
            return false
        }

        parentSprite.node.position = position
        parentSprite.node.physicsBody?.velocity = velocity

        guard let parentSpriteInitialVelocity = parentSprite.node.physicsBody?.velocity else {
            return false
        }

        guard let closestBolt = findClosestBolt(from: parentSprite.node.position) else {
            return false
        }

        if let prevAttachedBolt = hook.prevHookTo {
            let isAttachingToSameBolt = prevAttachedBolt.node.position == closestBolt.node.position
            if isAttachingToSameBolt {
                attachToSameBolt(sprite: parentSprite, bolt: closestBolt)
            }

            if !isAttachingToSameBolt {
                boostVelocity(of: parentSprite, withRespectTo: prevAttachedBolt)
            }
        }

        let anchor = parentSprite.makeAnchor(from: closestBolt)
        let line = parentSprite.makeLine(to: closestBolt)

        guard let anchorLineJointPin = makeJointPinToLine(from: anchor, toLine: line),
            let spriteLineJointPin = makeJointPinToLine(from: parentSprite.node, toLine: line) else {
                return false
        }
        parentSprite.node.physicsBody?.applyImpulse(parentSpriteInitialVelocity)

        systemHook.hookTo = closestBolt
        systemHook.anchor = anchor
        systemHook.line = line
        systemHook.anchorLineJointPin = anchorLineJointPin
        systemHook.parentLineJointPin = spriteLineJointPin

        return true
    }

    func unhookFrom(entity: Entity) -> Bool {
        guard let sprite = entity.getSpriteComponent() else {
            return false
        }

        guard let velocity = sprite.node.physicsBody?.velocity else {
            return false
        }

        return unhookFrom(entity: entity, at: sprite.node.position, with: velocity)
    }

    func unhookFrom(entity: Entity, at position: CGPoint, with velocity: CGVector) -> Bool {
        guard let hook = entity.getHookComponent() else {
            return false
        }

        guard let sprite = entity.getSpriteComponent() else {
            return false
        }

        sprite.node.position = position
        sprite.node.physicsBody?.velocity = velocity

        hook.prevHookTo = hook.hookTo
        hook.hookTo = nil
        hook.anchor = nil
        hook.line = nil
        hook.anchorLineJointPin = nil
        hook.parentLineJointPin = nil

        return true
    }

    private func getParentSprite(of hook: HookComponent) -> SpriteComponent? {
        return hook.parent.getSpriteComponent()
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

    private func boostVelocity(of sprite: SpriteComponent, withRespectTo bolt: SpriteComponent) {
        var boostX = 750
        let boostY = -750

        let isInFrontOfBolt = sprite.node.position.x > bolt.node.position.x

        if isInFrontOfBolt {
            boostX *= -1
        }

        let boost = CGVector(dx: boostX, dy: boostY)
        sprite.node.physicsBody?.applyImpulse(boost)
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
